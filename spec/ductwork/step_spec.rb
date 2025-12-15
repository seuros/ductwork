# frozen_string_literal: true

RSpec.describe Ductwork::Step do
  describe "validations" do
    let(:node) { "MyStep.0" }
    let(:klass) { "MyStep" }
    let(:status) { "in_progress" }
    let(:to_transition) { :expand }

    it "is invalid if the `node` is not present" do
      step = described_class.new(klass:, status:, to_transition:)

      expect(step).not_to be_valid
      expect(step.errors.full_messages).to eq(["Node can't be blank"])
    end

    it "is invalid if the `klass` is not present" do
      step = described_class.new(node:, status:, to_transition:)

      expect(step).not_to be_valid
      expect(step.errors.full_messages).to eq(["Klass can't be blank"])
    end

    it "is invalid if the `status` is not present" do
      step = described_class.new(node:, klass:, to_transition:)

      expect(step).not_to be_valid
      expect(step.errors.full_messages).to eq(["Status can't be blank"])
    end

    it "is invalid if the `to_transition` is not present" do
      step = described_class.new(node:, klass:, status:)

      expect(step).not_to be_valid
      expect(step.errors.full_messages).to eq(["To transition can't be blank"])
    end

    it "is valid otherwise" do
      step = described_class.new(node:, klass:, status:, to_transition:)

      expect(step).to be_valid
    end
  end
end
