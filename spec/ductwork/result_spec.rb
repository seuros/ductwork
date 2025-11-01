# frozen_string_literal: true

RSpec.describe Ductwork::Result do
  describe "validations" do
    let(:result_type) { described_class.result_types.keys.sample }

    it "is invalid when started_at is blank" do
      result = described_class.new

      expect(result).not_to be_valid
      expect(result.errors.full_messages.sole).to eq("Result type can't be blank")
    end

    it "is valid otherwise" do
      result = described_class.new(result_type:)

      expect(result).to be_valid
    end
  end
end
