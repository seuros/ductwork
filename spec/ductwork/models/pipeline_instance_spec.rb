# frozen_string_literal: true

RSpec.describe Ductwork::PipelineInstance do
  describe "validations" do
    let(:name) { "MyPipeline" }
    let(:triggered_at) { Time.current }
    let(:status) { "in_progress" }

    it "is invalid if the `name` is not present" do
      instance = described_class.new(triggered_at:, status:)

      expect(instance).not_to be_valid
      expect(instance.errors.full_messages).to eq(["Name can't be blank"])
    end

    it "is invalid if the name is already taken" do
      described_class.create!(name:, triggered_at:, status:)

      instance = described_class.new(name:, triggered_at:, status:)

      expect(instance).not_to be_valid
      expect(instance.errors.full_messages).to eq(["Name has already been taken"])
    end

    it "is invalid if `triggered_at` is not present" do
      instance = described_class.new(name:, status:)

      expect(instance).not_to be_valid
      expect(instance.errors.full_messages).to eq(["Triggered at can't be blank"])
    end

    it "is invalid if `status` is not present" do
      instance = described_class.new(name:, triggered_at:)

      expect(instance).not_to be_valid
      expect(instance.errors.full_messages).to eq(["Status can't be blank"])
    end

    it "is valid otherwise" do
      instance = described_class.new(name:, triggered_at:, status:)

      expect(instance).to be_valid
    end
  end
end
