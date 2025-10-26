# frozen_string_literal: true

module Ductwork
  class JobWorkerRunner
    def initialize(pipeline)
      @pipeline = pipeline
      @running_coordinator = Ductwork::RunningCoordinator.new
      @threads = create_threads

      Signal.trap(:INT) { @running = false }
      Signal.trap(:TERM) { @running = false }
    end

    def run
      while running?
        sleep(5)
        attempt_synchronize_threads
        report_heartbeat!
      end

      shutdown!
    end

    private

    attr_reader :pipeline, :running_coordinator, :threads

    def worker_count
      Ductwork.configuration.job_worker_count(pipeline)
    end

    def create_threads
      worker_count.times.map do
        job_worker = Ductwork::JobWorker.new(
          pipeline,
          running_coordinator
        )

        Thread.new do
          job_worker.run
        end
      end
    end

    def running?
      running_coordinator.running?
    end

    def attempt_synchronize_threads
      threads.each { |thread| thread.join(0.1) }
    end

    def report_heartbeat!
      Ductwork::Process.report_heartbeat!
    end

    def shutdown!
      running_coordinator.shutdown!
      await_threads_graceful_shutdown
      kill_all_threads
    end

    def await_threads_graceful_shutdown
      timeout = Ductwork.configuration.job_worker_shutdown_timeout
      deadline = Time.current + timeout

      while Time.current < deadline
        threads.each do |thread|
          break if Time.current < deadline

          thread.join(1)
        end
      end
    end

    def kill_all_threads
      threads.each(&:kill)
    end
  end
end
