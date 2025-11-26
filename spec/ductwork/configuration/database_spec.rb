# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#database" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          database: pipeline_db

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the timeout" do
      config = described_class.new

      expect(config.database).to eq("pipeline_db")
    end
  end

  context "when no config file exists" do
    it "returns nil" do
      config = described_class.new

      expect(config.database).to be_nil
    end
  end
end
