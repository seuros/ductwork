# frozen_string_literal: true

module Ductwork
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def create_files
      template "config/ductwork.yml"
      template "bin/ductwork"
      chmod "bin/ductwork", 0o755 & ~File.umask, verbose: false
    end
  end
end
