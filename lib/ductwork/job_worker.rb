# frozen_string_literal: true

module Ductwork
  class JobWorker
    def initialize(pipeline)
      @pipeline = pipeline
      @running = true
      # TODO: don't handle signals in threads
      Signal.trap(:INT) { @running = false }
      Signal.trap(:TERM) { @running = false }
    end

    def run
      while running
        job = claim_job

        if job.present?
          process_job(job)
        else
          # TODO: log
        end
      end
    end

    private

    attr_reader :pipeline, :running

    def claim_job
      process_id = Process.pid
      id = Ductwork::Availability
           .where(completed_at: nil)
           .order(:created_at)
           .limit(1)
           .pluck(:id)
           .first

      if id.present?
        # TODO: probably makes sense to use SQL here instead of relying
        # on ActiveRecord to construct the correct `UPDATE` query
        rows_updated = Ductwork::Availability
                       .where(id:, completed_at: nil)
                       .update_all(completed_at: Time.current, process_id:)

        if rows_updated == 1
          Ductwork::Job
            .joins(executions: :availability)
            .find_by(availabilities: { id:, process_id: })
        end
      end
    end

    def process_job(job)
      # WERK
    end
  end
end
