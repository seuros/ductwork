# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#forking" do
  include ConfigurationFileHelper

  context "when the configuration file exists" do
    let(:data) do
      <<~DATA
        default: &default
          forking: none

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the forking configuration value" do
      config = described_class.new

      expect(config.forking).to eq("none")
    end
  end

  context "when no configuration file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.forking).to eq("default")
    end
  end
end
