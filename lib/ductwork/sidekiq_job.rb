# frozen_string_literal: true

module Ductwork
  class SidekiqJob
    include Sidekiq::Job

    def perform(klass, *args)
      return_value = klass.constantize.new.perform(*args)
      job = Job.find_by!(jid: jid)
      job.update!(
        completed_at: Time.current,
        status: "completed",
        return_value: return_value
      )
    end
  end
end
