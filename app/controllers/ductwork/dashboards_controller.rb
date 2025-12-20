# frozen_string_literal: true

module Ductwork
  class DashboardsController < Ductwork::ApplicationController
    def show
      @metrics = Ductwork::Pipeline
                 .group(:status)
                 .count
                 .slice("completed", "in_progress", "halted")
                 .with_indifferent_access
                 .reverse_merge(completed: 0, in_progress: 0, halted: 0)
      @metrics[:step_errors] = Ductwork::Result.failure.count
      @klasses = Ductwork::Pipeline.group(:klass).pluck(:klass).sort
      @statuses = Ductwork::Pipeline.statuses.keys
      @per_page = 25
      @pipelines = query_pipelines
    end
  end
end
