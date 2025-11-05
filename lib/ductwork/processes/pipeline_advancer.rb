# frozen_string_literal: true

module Ductwork
  module Processes
    class PipelineAdvancer
      def initialize(running_context, *klasses)
        @running_context = running_context
        @klasses = klasses
      end

      def call # rubocop:disable Metrics
        logger.debug(msg: "Advancing pipelines", role: :pipeline_advancer)

        steps_to_advance.find_each do |step| # rubocop:disable Metrics/BlockLength
          break if !running_context.running?

          pipeline = step.pipeline
          definition = JSON.parse(pipeline.definition).with_indifferent_access
          edge = definition.dig(:edges, step.klass, 0)

          # NOTE: sigh, apologies to anyone reading this... there's a lot of
          # conditional branching here that makes this a huge mess along
          # with random argument deserialization/serialization. slowly
          # cleaining this up
          Ductwork::Record.transaction do # rubocop:disable Metrics/BlockLength
            step.update!(status: :completed, completed_at: Time.current)

            if edge.nil?
              if !pipeline.steps.where.not(status: :completed).exists?
                pipeline.update!(status: :completed, completed_at: Time.current)
              end
            else
              # NOTE: "chain" is used by ActiveRecord so we have to call
              # this enum value "default" :sad:
              step_type = edge[:type] == "chain" ? "default" : edge[:type]

              if step_type.in?(%w[default divide])
                edge[:to].each do |klass|
                  next_step = pipeline.steps.create!(
                    klass: klass,
                    status: :in_progress,
                    step_type: step_type,
                    started_at: Time.current
                  )
                  Ductwork::Job.enqueue(next_step, step.job.return_value)
                end
              elsif step_type == "combine"
                previous_klasses = definition[:edges].select do |_, v|
                  v.dig(0, :to, 0) == edge[:to].sole && v.dig(0, :type) == "combine"
                end.keys

                if pipeline.steps.not_completed.where(klass: previous_klasses).none?
                  input_arg = Job.where(
                    step: pipeline.steps.completed.where(klass: previous_klasses)
                  ).map(&:return_value)
                  create_step_and_enqueue_job(
                    pipeline: pipeline,
                    klass: edge[:to].sole,
                    step_type: step_type,
                    input_arg: input_arg
                  )
                end
              elsif step_type == "expand"
                step.job.return_value.each do |input_arg|
                  create_step_and_enqueue_job(
                    pipeline: pipeline,
                    klass: edge[:to].sole,
                    step_type: step_type,
                    input_arg: input_arg
                  )
                end
              elsif step_type == "collapse"
                if pipeline.steps.not_completed.where(klass: step.klass).none?
                  input_arg = Job.where(
                    step: pipeline.steps.completed.where(klass: step.klass)
                  ).map(&:return_value)
                  create_step_and_enqueue_job(
                    pipeline: pipeline,
                    klass: edge[:to].sole,
                    step_type: step_type,
                    input_arg: input_arg
                  )
                else
                  logger.debug(msg: "Not all expanded steps have completed", role: :pipeline_advancer)
                end
              else
                logger.error("Invalid step type? This is wrong lol", role: :pipeline_advancer)
              end
            end
          end
        end

        logger.debug(msg: "Advanced pipelines", role: :pipeline_advancer)
      end

      private

      attr_reader :running_context, :klasses

      def steps_to_advance
        Ductwork::Step
          .advancing
          .joins(:pipeline)
          .where(ductwork_pipelines: { klass: klasses })
      end

      # NOTE: this probably should be a method on a model(s) or something
      # because a job is always going to be enqueued when a new in-progress
      # step is created :think:
      def create_step_and_enqueue_job(pipeline:, klass:, step_type:, input_arg:)
        status = :in_progress
        started_at = Time.current
        next_step = pipeline.steps.create!(klass:, status:, step_type:, started_at:)
        Ductwork::Job.enqueue(next_step, input_arg)
      end

      def logger
        Ductwork.configuration.logger
      end
    end
  end
end
