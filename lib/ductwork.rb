# frozen_string_literal: true

require "concurrent-ruby"

require_relative "ductwork/definition"
require_relative "ductwork/definition_builder"
require_relative "ductwork/pipeline"
require_relative "ductwork/version"

module Ductwork
  class << self
    def definitions
      @_definitions ||= Concurrent::Hash.new
    end

    # NOTE: this is test interface only!
    def reset!
      @_definitions = nil
    end
  end
end
