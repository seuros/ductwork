# frozen_string_literal: true

module Ductwork
  class StepErrorsController < Ductwork::ApplicationController
    def index
      @step_errors = query_step_errors
      @klasses = Ductwork::Result.failure.joins(execution: { job: :step }).group("ductwork_steps.klass").pluck("ductwork_steps.klass")
    end

    private

    def query_step_errors
      Ductwork::Result
        .failure
        .then(&method(:filter_by_step_klass))
        .then(&method(:paginate))
        .includes(execution: { job: :step })
        .order(created_at: :desc)
    end

    def filter_by_step_klass(relation)
      if params[:klass].present?
        relation
          .joins(execution: { job: :step })
          .where(ductwork_steps: { klass: params[:klass] })
      else
        relation
      end
    end
  end
end
