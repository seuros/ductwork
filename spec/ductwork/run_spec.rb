# frozen_string_literal: true

RSpec.describe Ductwork::Run do
  describe "validations" do
    let(:started_at) { Time.current }

    it "is invalid when started_at is blank" do
      run = described_class.new

      expect(run).not_to be_valid
      expect(run.errors.full_messages.sole).to eq("Started at can't be blank")
    end

    it "is valid otherwise" do
      run = described_class.new(started_at:)

      expect(run).to be_valid
    end
  end
end
