# frozen_string_literal: true

RSpec.describe Ductwork::DSL::DefinitionBuilder do
  let(:builder) { described_class.new }

  describe "#chain" do
    it "returns the builder instance" do
      returned_builder = builder.start(MyFirstStep).chain(MySecondStep)

      expect(returned_builder).to eq(builder)
    end

    it "adds a new step to the current branch of the definition" do
      definition = builder.start(MyFirstStep).chain(MySecondStep).complete

      expect(definition[:nodes]).to eq(%w[MyFirstStep MySecondStep])
      expect(definition[:edges].length).to eq(2)
      expect(definition[:edges]["MyFirstStep"]).to eq(
        [
          { to: %w[MySecondStep], type: :chain },
        ]
      )
      expect(definition[:edges]["MySecondStep"]).to eq([])
    end

    it "adds a new step for each active branch of the definition" do
      definition = builder
                   .start(MyFirstStep)
                   .divide(to: [MySecondStep, MyThirdStep])
                   .chain(MyFourthStep)
                   .complete

      expect(definition[:edges]["MyFirstStep"]).to eq(
        [{ to: %w[MySecondStep MyThirdStep], type: :divide }]
      )
      expect(definition[:edges]["MySecondStep"]).to eq(
        [{ to: %w[MyFourthStep], type: :chain }]
      )
      expect(definition[:edges]["MyThirdStep"]).to eq(
        [{ to: %w[MyFourthStep], type: :chain }]
      )
    end

    it "raises if the argument is not a class" do
      expect do
        builder.start(MyFirstStep).chain("MySecondStep")
      end.to raise_error(
        ArgumentError,
        "Argument must be a valid step class"
      )
    end

    it "raises if the argument does not have an 'execute' method" do
      expect do
        builder.start(MyFirstStep).chain(Class.new)
      end.to raise_error(
        ArgumentError,
        "Argument must be a valid step class"
      )
    end

    it "raises if the argument does not have `execute` with arity zero" do
      klass = Class.new do
        def execute(_foobar); end
      end

      expect do
        builder.start(MyFirstStep).chain(klass)
      end.to raise_error(
        ArgumentError,
        "Argument must be a valid step class"
      )
    end

    it "raises if pipeline has not been started" do
      expect do
        builder.chain(MyFirstStep)
      end.to raise_error(
        described_class::StartError,
        "Must start pipeline definition before chaining"
      )
    end
  end
end
