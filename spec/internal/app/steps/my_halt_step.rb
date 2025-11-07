# frozen_string_literal: true

class MyHaltStep
  def initialize(error)
    @error = error
  end

  def execute
    puts "!" * 80
    puts error
    puts "!" * 80
  end

  private

  attr_reader :error
end
