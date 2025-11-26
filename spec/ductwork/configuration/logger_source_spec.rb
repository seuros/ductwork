# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#logger_source" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          logger:
            source: rails

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the logger source" do
      config = described_class.new

      expect(config.logger_source).to eq("rails")
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.logger_source).to eq("default")
    end
  end
end
