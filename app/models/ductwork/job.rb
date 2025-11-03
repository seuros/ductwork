# frozen_string_literal: true

module Ductwork
  class Job < Ductwork::Record
    belongs_to :step, class_name: "Ductwork::Step"
    has_many :executions, class_name: "Ductwork::Execution", foreign_key: "job_id", dependent: :destroy

    validates :klass, presence: true
    validates :started_at, presence: true
    validates :input_args, presence: true

    def self.claim_latest
      process_id = ::Process.pid
      id = Ductwork::Availability
           .where(completed_at: nil)
           .order(:created_at)
           .limit(1)
           .pluck(:id)
           .first

      if id.present?
        # TODO: probably makes sense to use SQL here instead of relying
        # on ActiveRecord to construct the correct `UPDATE` query
        rows_updated = nil
        Ductwork::Record.transaction do
          rows_updated = Ductwork::Availability
                         .where(id:, completed_at: nil)
                         .update_all(completed_at: Time.current, process_id:)
          Ductwork::Execution
            .joins(:availability)
            .where(completed_at: nil)
            .where(ductwork_availabilities: { id: id })
            .update_all(process_id: process_id)
        end

        if rows_updated == 1
          Ductwork.configuration.logger.debug(
            msg: "Job claimed",
            role: :job_worker,
            process_id: process_id,
            availability_id: id
          )
          Ductwork::Job
            .joins(executions: :availability)
            .find_by(ductwork_availabilities: { id:, process_id: })
        else
          Ductwork.configuration.logger.debug(
            msg: "Did not claim job, avoided race condition",
            role: :job_worker,
            process_id: process_id,
            availability_id: id
          )
          nil
        end
      end
    end

    def self.enqueue(step, *args)
      job = step.create_job!(
        klass: step.klass,
        started_at: Time.current,
        input_args: JSON.dump(args)
      )
      execution = job.executions.create!(
        started_at: Time.current
      )
      execution.create_availability!(
        started_at: Time.current
      )

      job
    end

    def execute(pipeline) # rubocop:disable Metrics/AbcSize
      # i don't _really_ like this, but it should be fine for now...
      execution = executions.order(:created_at).last
      logger.debug(
        msg: "Executing job",
        role: :job_worker,
        pipeline: pipeline,
        job_klass: klass
      )
      instance = Object.const_get(klass).new(input_args)
      run = execution.create_run!(
        started_at: Time.current
      )
      begin
        output_payload = instance.execute
        Ductwork::Record.transaction do
          update!(output_payload: output_payload)
          run.update!(completed_at: Time.current)
          execution.update!(completed_at: Time.current)
        end
        execution.create_result!(result_type: "success")
      rescue StandardError => e
        Ductwork::Record.transaction do
          run.update!(completed_at: Time.current)
          execution.update!(completed_at: Time.current)
        end
        execution.create_result!(
          result_type: "failure",
          error_klass: e.class.to_s,
          error_message: e.message,
          error_backtrace: e.backtrace
        )
      ensure
        logger.debug(
          msg: "Executed job",
          role: :job_worker,
          pipeline: pipeline,
          job_klass: klass
        )
      end
    end

    private

    def logger
      Ductwork.configuration.logger
    end
  end
end
