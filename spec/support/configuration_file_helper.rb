# frozen_string_literal: true

require "fileutils"

module ConfigurationFileHelper
  RSpec.configure do |config|
    config.after do
      if defined?(config_file)
        config_file.close
        config_file.unlink
      end

      if File.directory?("config")
        FileUtils.rm_rf("config")
      end
    end
  end

  def create_temp_file
    Tempfile.new("ductwork.yml").tap do |file|
      file.write(data)
      file.rewind
    end
  end

  def create_default_config_file
    if !File.directory?("config")
      FileUtils.mkdir_p("config")
    end

    File.new("config/ductwork.yml", "w").tap do |file|
      file.write(data)
      file.rewind
    end
  end
end
