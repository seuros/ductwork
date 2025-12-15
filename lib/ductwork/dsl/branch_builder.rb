# frozen_string_literal: true

module Ductwork
  module DSL
    class BranchBuilder
      class CollapseError < StandardError; end

      attr_reader :last_node

      def initialize(klass:, definition:, stages:)
        @last_node = "#{klass.name}.#{stages.length - 1}"
        @definition = definition
        @stages = stages
        @expansions = 0
      end

      def chain(next_klass)
        next_klass_name = "#{next_klass.name}.#{stages.length}"
        definition[:edges][last_node][:to] = [next_klass_name]
        definition[:edges][last_node][:type] = :chain
        definition[:nodes].push(next_klass_name)
        definition[:edges][next_klass_name] ||= { klass: next_klass.name }
        stages.push(1)
        @last_node = next_klass_name

        self
      end

      def divide(to:) # rubocop:todo Metrics/AbcSize
        next_klass_names = to.map { |klass| "#{klass.name}.#{stages.length}" }
        definition[:edges][last_node][:to] = next_klass_names
        definition[:edges][last_node][:type] = :divide
        definition[:nodes].push(*next_klass_names)
        stages.push(1)

        sub_branches = to.map do |klass|
          next_klass_name = "#{klass.name}.#{stages.length - 1}"
          definition[:edges][next_klass_name] ||= { klass: klass.name }

          Ductwork::DSL::BranchBuilder.new(klass:, definition:, stages:)
        end

        yield sub_branches

        self
      end

      def combine(*branch_builders, into:) # rubocop:todo Metrics/AbcSize
        next_klass_name = "#{into.name}.#{stages.length}"
        definition[:edges][last_node][:to] = [next_klass_name]
        definition[:edges][last_node][:type] = :combine

        branch_builders.each do |branch|
          definition[:edges][branch.last_node][:to] = [next_klass_name]
          definition[:edges][branch.last_node][:type] = :combine
        end
        definition[:nodes].push(next_klass_name)
        definition[:edges][next_klass_name] ||= { klass: into.name }
        stages.push(1)

        self
      end

      def expand(to:)
        next_klass_name = "#{to.name}.#{stages.length}"
        definition[:edges][last_node][:to] = [next_klass_name]
        definition[:edges][last_node][:type] = :expand
        definition[:nodes].push(next_klass_name)
        definition[:edges][next_klass_name] ||= { klass: to.name }
        stages.push(1)
        @last_node = next_klass_name
        @expansions += 1

        self
      end

      def collapse(into:)
        if expansions.zero?
          raise CollapseError,
                "Must expand pipeline definition before collapsing steps"
        end

        next_klass_name = "#{into.name}.#{stages.length}"
        definition[:edges][last_node][:to] = [next_klass_name]
        definition[:edges][last_node][:type] = :collapse

        definition[:nodes].push(next_klass_name)
        definition[:edges][next_klass_name] ||= { klass: into.name }
        stages.push(1)
        @last_node = into.name
        @expansions -= 1

        self
      end

      private

      attr_reader :definition, :expansions, :stages
    end
  end
end
