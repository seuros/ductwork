# frozen_string_literal: true

module Ductwork
  class PipelinesController < Ductwork::ApplicationController
    def index
      @pipelines = query_pipelines
      @klasses = Ductwork::Pipeline.group(:klass).pluck(:klass).sort
      @statuses = Ductwork::Pipeline.statuses.keys
    end

    def show
      @pipeline = Ductwork::Pipeline.find(params[:id])
      @per_page = 10
      @steps = query_steps
      @klasses = @pipeline.steps.group(:klass).pluck(:klass).sort
      @statuses = Ductwork::Step.statuses.keys
    end

    private

    def query_steps
      @pipeline
        .steps
        .then(&method(:filter_by_klass))
        .then(&method(:filter_by_status))
        .then(&method(:paginate))
        .order(:started_at)
    end
  end
end
