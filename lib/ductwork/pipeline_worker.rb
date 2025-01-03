# frozen_string_literal: true

module Ductwork
  class PipelineWorker
    def initialize(pipeline_name)
      @pipeline_name = pipeline_name
      @running = true
      Signal.trap(:INT) { @running = false }
      Signal.trap(:TERM) { @running = false }
    end

    def run
      while running
        update_pipelines
        sleep(1)
      end
    end

    private

    attr_reader :pipeline_name, :running

    def update_pipelines
      pipelines.find_each do |pipeline|
        # TODO: implement
        # pipeline.steps.active.find_each do |step|
        #   break if !running
        # end
        # break if !running
      end
    end

    def pipelines
      Ductwork::PipelineInstance.in_progress.where(name: pipeline_name)
    end
  end
end
