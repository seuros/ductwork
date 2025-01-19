# frozen_string_literal: true

require "debug"
require "bundler"

require "ductwork"

Bundler.require :default, :development
Combustion.initialize! :active_record

require "rspec/rails"
require "sidekiq/testing"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand(config.seed)

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Ductwork.reset!

    # Simulate railtie loading the configuration for each example
    path = Rails.root.join("config/ductwork.yml")
    Ductwork.configuration ||= Ductwork::Configuration.new(path: path)
  end
end
