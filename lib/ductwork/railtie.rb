# frozen_string_literal: true

module Ductwork
  class Railtie < ::Rails::Railtie
    initializer "ductwork.load_models" do
      ActiveSupport.on_load(:active_record) do
        require "ductwork/models"
      end
    end
  end
end
