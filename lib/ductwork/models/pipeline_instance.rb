# frozen_string_literal: true

module Ductwork
  class PipelineInstance < Ductwork::Record
    validates :name, uniqueness: true, presence: true
    validates :status, presence: true
    validates :triggered_at, presence: true

    enum :status,
         pending: "pending",
         in_progress: "in_progress",
         completed: "completed"
  end
end
