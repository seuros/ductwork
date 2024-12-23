# frozen_string_literal: true

module Ductwork
  module Pipeline
    class DefinitionError < StandardError; end

    module ClassMethods
      def define(&block)
        if !block_given?
          raise DefinitionError, "Definition block must be given"
        end

        if Ductwork.definitions.key?(self)
          raise DefinitionError, "Pipeline has already been defined"
        end

        builder = DefinitionBuilder.new

        block.call(builder)

        Ductwork.definitions[self] = builder.complete!
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
