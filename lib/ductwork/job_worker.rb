# frozen_string_literal: true

module Ductwork
  class JobWorker
    def initialize(pipeline, running_context)
      @pipeline = pipeline
      @running_context = running_context
    end

    def run
      logger.debug(
        msg: "Entering main work loop",
        role: :job_worker,
        pipeline: pipeline
      )
      while running_context.running?
        logger.debug(
          msg: "Attempting to claim job",
          role: :job_worker,
          pipeline: pipeline
        )
        job = Job.claim_latest

        if job.present?
          job.execute(pipeline)
        else
          logger.debug(
            msg: "No job to claim, looping",
            role: :job_worker,
            pipeline: pipeline
          )
          sleep(1)
        end
      end

      shutdown
    end

    private

    attr_reader :pipeline, :running_context

    def shutdown
      logger.debug(
        msg: "Shutting down",
        role: :job_worker,
        pipeline: pipeline
      )
    end

    def logger
      Ductwork.configuration.logger
    end
  end
end
