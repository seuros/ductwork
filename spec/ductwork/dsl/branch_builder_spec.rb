# frozen_string_literal: true

RSpec.describe Ductwork::DSL::BranchBuilder do
  describe "#chain" do
    subject(:builder) { described_class.new(klass:, definition:, stages:) }

    let(:klass) { MyFirstStep }
    # NOTE: we can assume the definition has at least this state because
    # this class is only used in the `DefinitionBuilder`
    let(:definition) do
      {
        nodes: %w[MyFirstStep.0],
        edges: {
          "MyFirstStep.0" => { klass: "MyFirstStep" },
        },
      }
    end
    let(:stages) { [1] }

    it "returns itself" do
      instance = builder.chain(MySecondStep)

      expect(instance).to eq(builder)
    end

    it "adds a new node and edge to the definition" do
      builder.chain(MySecondStep)

      expect(definition[:nodes]).to eq(%w[MyFirstStep.0 MySecondStep.1])
      expect(definition[:edges]["MyFirstStep.0"]).to eq(
        { to: %w[MySecondStep.1], type: :chain, klass: "MyFirstStep" }
      )
      expect(definition[:edges]["MySecondStep.1"]).to eq({ klass: "MySecondStep" })
    end
  end

  describe "#divide" do
    subject(:builder) { described_class.new(klass:, definition:, stages:) }

    let(:klass) { MyFirstStep }
    # NOTE: we can assume the definition has at least this state because
    # this class is only used in the `DefinitionBuilder`
    let(:definition) do
      {
        nodes: %w[MyFirstStep.0],
        edges: {
          "MyFirstStep.0" => { klass: "MyFirstStep" },
        },
      }
    end
    let(:stages) { [1] }

    it "returns itself" do
      instance = builder.divide(to: [MySecondStep, MyThirdStep]) {} # rubocop:disable Lint/EmptyBlock

      expect(instance).to eq(builder)
    end

    it "adds a new node and edge to the definition" do
      builder.divide(to: [MySecondStep, MyThirdStep]) {} # rubocop:disable Lint/EmptyBlock

      expect(definition[:nodes]).to eq(
        %w[MyFirstStep.0 MySecondStep.1 MyThirdStep.1]
      )
      expect(definition[:edges]["MyFirstStep.0"]).to eq(
        { to: %w[MySecondStep.1 MyThirdStep.1], type: :divide, klass: "MyFirstStep" }
      )
      expect(definition[:edges]["MySecondStep.1"]).to eq({ klass: "MySecondStep" })
      expect(definition[:edges]["MyThirdStep.1"]).to eq({ klass: "MyThirdStep" })
    end

    it "yields the sub-branches to the block" do
      expect do |block|
        builder.divide(to: [MySecondStep, MyThirdStep], &block)
      end.to yield_control
    end
  end

  describe "#combine" do
    subject(:builder) { described_class.new(klass:, definition:, stages:) }

    let(:other_builder) do
      described_class.new(klass: MySecondStep, definition: definition, stages: stages)
    end
    let(:klass) { MyFirstStep }
    # NOTE: we can assume the definition has at least this state because
    # this class is only used in the `DefinitionBuilder`
    let(:definition) do
      {
        nodes: %w[MyFirstStep.1 MySecondStep.1],
        edges: {
          "MyFirstStep.1" => { klass: "MyFirstStep" },
          "MySecondStep.1" => { klass: "MySecondStep" },
        },
      }
    end
    let(:stages) { [1, 1] }

    it "returns itself" do
      instance = builder.combine(other_builder, into: MyThirdStep)

      expect(instance).to eq(builder)
    end

    it "combines the branch builder into the given step" do
      builder.combine(other_builder, into: MyThirdStep)

      expect(definition[:nodes]).to eq(
        %w[MyFirstStep.1 MySecondStep.1 MyThirdStep.2]
      )
      expect(definition[:edges]["MyFirstStep.1"]).to eq(
        { to: %w[MyThirdStep.2], type: :combine, klass: "MyFirstStep" }
      )
      expect(definition[:edges]["MySecondStep.1"]).to eq(
        { to: %w[MyThirdStep.2], type: :combine, klass: "MySecondStep" }
      )
    end

    it "combines multiple branch builders into the given step" do
      builder, *other_builders = [
        described_class.new(klass: MyFirstStep, definition: definition, stages: stages),
        described_class.new(klass: MySecondStep, definition: definition, stages: stages),
        described_class.new(klass: MyThirdStep, definition: definition, stages: stages),
      ]
      definition[:nodes].push("MyThirdStep.1")
      definition[:edges]["MyThirdStep.1"] = { klass: "MyThirdStep" }

      builder.combine(*other_builders, into: MyFourthStep)

      expect(definition[:edges]["MyFirstStep.1"]).to eq(
        { to: %w[MyFourthStep.2], type: :combine, klass: "MyFirstStep" }
      )
      expect(definition[:edges]["MySecondStep.1"]).to eq(
        { to: %w[MyFourthStep.2], type: :combine, klass: "MySecondStep" }
      )
      expect(definition[:edges]["MyThirdStep.1"]).to eq(
        { to: %w[MyFourthStep.2], type: :combine, klass: "MyThirdStep" }
      )
      expect(definition[:edges]["MyFourthStep.2"]).to eq({ klass: "MyFourthStep" })
    end
  end

  describe "#expand" do
    subject(:builder) { described_class.new(klass:, definition:, stages:) }

    let(:klass) { MyFirstStep }
    # NOTE: we can assume the definition has at least this state because
    # this class is only used in the `DefinitionBuilder`
    let(:definition) do
      {
        nodes: %w[MyFirstStep.0],
        edges: {
          "MyFirstStep.0" => { klass: "MyFirstStep" },
        },
      }
    end
    let(:stages) { [1] }

    it "returns itself" do
      instance = builder.expand(to: MySecondStep)

      expect(instance).to eq(builder)
    end

    it "adds a new node and edge to the definition" do
      builder.expand(to: MySecondStep)

      expect(definition[:nodes]).to eq(%w[MyFirstStep.0 MySecondStep.1])
      expect(definition[:edges]["MyFirstStep.0"]).to eq(
        { to: %w[MySecondStep.1], type: :expand, klass: "MyFirstStep" }
      )
      expect(definition[:edges]["MySecondStep.1"]).to eq({ klass: "MySecondStep" })
    end
  end

  describe "#collapse" do
    subject(:builder) { described_class.new(klass:, definition:, stages:) }

    let(:klass) { MyFirstStep }
    # NOTE: we can assume the definition has at least this state because
    # this class is only used in the `DefinitionBuilder`
    let(:definition) do
      {
        nodes: %w[MyFirstStep.0],
        edges: {
          "MyFirstStep.0" => { klass: "MyFirstStep" },
        },
      }
    end
    let(:stages) { [1] }

    before do
      builder.expand(to: MySecondStep)
    end

    it "returns itself" do
      instance = builder.collapse(into: MyThirdStep)

      expect(instance).to eq(builder)
    end

    it "adds a new node and edge to the definition" do
      builder.collapse(into: MyThirdStep)

      expect(definition[:nodes]).to eq(
        %w[MyFirstStep.0 MySecondStep.1 MyThirdStep.2]
      )
      expect(definition[:edges]["MyFirstStep.0"]).to eq(
        { to: %w[MySecondStep.1], type: :expand, klass: "MyFirstStep" }
      )
      expect(definition[:edges]["MySecondStep.1"]).to eq(
        { to: %w[MyThirdStep.2], type: :collapse, klass: "MySecondStep" }
      )
      expect(definition[:edges]["MyThirdStep.2"]).to eq({ klass: "MyThirdStep" })
    end

    it "raises when the branch definition has not been expanded" do
      definition = {
        nodes: %w[MyFirstStep.0],
        edges: { "MyFirstStep.0" => { klass: "MyFirstStep" } },
      }
      builder = described_class.new(klass: MyFirstStep, definition: definition, stages: stages)

      expect do
        builder.collapse(into: MySecondStep)
      end.to raise_error(
        described_class::CollapseError,
        "Must expand pipeline definition before collapsing steps"
      )
    end
  end
end
