# frozen_string_literal: true

module Ductwork
  class Engine < ::Rails::Engine
    initializer "configure" do
      Ductwork.configuration ||= Ductwork::Configuration.new
      Ductwork.configuration.logger = ::Rails.logger
    end
  end
end
