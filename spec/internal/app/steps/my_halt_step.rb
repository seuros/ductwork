# frozen_string_literal: true

class MyHaltStep < Ductwork::Step
  def initialize(error)
    @error = error
  end

  def execute; end

  private

  attr_reader :error
end
