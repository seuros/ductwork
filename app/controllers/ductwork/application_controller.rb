# frozen_string_literal: true

module Ductwork
  class ApplicationController < ActionController::Base
    DEFAULT_PER_PAGE = 50

    def query_pipelines
      Ductwork::Pipeline
        .includes(steps: { job: { executions: :result }})
        .then(&method(:filter_by_klass))
        .then(&method(:filter_by_status))
        .then(&method(:paginate))
        .order(started_at: :desc)
    end

    def filter_by_klass(relation)
      if params[:klass].present?
        relation.where(klass: params[:klass])
      else
        relation
      end
    end

    def filter_by_status(relation)
      if params[:status].present?
        relation.where(status: params[:status])
      else
        relation
      end
    end

    def paginate(relation)
      per_page = @per_page || DEFAULT_PER_PAGE
      offset = params[:page].to_i * per_page

      relation.limit(per_page).offset(offset)
    end
  end
end
