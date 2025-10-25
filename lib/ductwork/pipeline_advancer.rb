# frozen_string_literal: true

module Ductwork
  class PipelineAdvancer
    def initialize(*klasses)
      @klasses = klasses
      @running = true
      Signal.trap(:INT) { @running = false }
      Signal.trap(:TERM) { @running = false }
    end

    def run
      while running
        advance_all_pipelines
        # TODO: update heartbeat
        sleep(1)
      end
    end

    def advance_all_pipelines
      pipelines.find_each do |pipeline|
        break if !running

        # 1. Query all other `steps` records in the same Stage/Branch
        # 2. If all steps are status "advancing", continue.
        #      Otherwise, Stage is not ready to advance
        # 3. Check if any `steps.job` has failed:
        #      If not, continue.
        #      If yes, halt pipeline and log
        # 4. Mark all `steps` in Stage as "completed"
        # 5. Create next Stage and all `steps` with status "in-progress" from pipeline definition
      end
    end

    private

    attr_reader :klasses, :running

    def pipelines
      Ductwork::Pipeline
        .joins(:steps)
        .where(klass: klasses)
        .where(steps: { status: "advancing" })
        .distinct
    end
  end
end
