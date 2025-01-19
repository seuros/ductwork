# frozen_string_literal: true

module Ductwork
  class Railtie < ::Rails::Railtie
    initializer "ductwork.load_models" do
      ActiveSupport.on_load(:active_record) do
        require "ductwork/models"
      end

      if defined?(Sidekiq)
        require "ductwork/sidekiq_wrapper_job"
      end

      path = Rails.root.join("config/ductwork.yml")
      Ductwork.configuration ||= Configuration.new(path: path)
    end
  end
end
