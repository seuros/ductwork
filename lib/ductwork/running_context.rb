# frozen_string_literal: true

module Ductwork
  class RunningContext
    def initialize
      @mutex = Mutex.new
      @running = true
    end

    def running?
      mutex.synchronize { running }
    end

    def shutdown!
      @running = false
    end

    private

    attr_reader :mutex, :running
  end
end
