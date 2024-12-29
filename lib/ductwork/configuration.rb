# frozen_string_literal: true

require "debug"

module Ductwork
  class Configuration
    DEFAULT_ENV = :default
    DEFAULT_FILE_PATH = "config/ductwork.yml"
    DELIMITER = ","

    class FileError < StandardError; end

    def initialize(path: DEFAULT_FILE_PATH)
      full_path = Pathname.new(path)
      data = ActiveSupport::ConfigurationFile.parse(full_path).deep_symbolize_keys
      env = defined?(Rails) ? Rails.env.to_sym : DEFAULT_ENV
      @config = data[env]
    rescue Errno::ENOENT
      raise FileError, "Missing configuration file"
    end

    def pipelines
      config.dig(:workers, 0, :pipelines).split(DELIMITER).map(&:strip)
    end

    private

    attr_reader :config
  end
end
