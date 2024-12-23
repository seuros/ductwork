# frozen_string_literal: true

module Ductwork
  class DefinitionBuilder
    def start(klass); end

    def complete!
      Ductwork::Definition.new
    end
  end
end
