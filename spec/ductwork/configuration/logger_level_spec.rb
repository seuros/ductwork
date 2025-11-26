# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#logger_level" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          logger:
            level: 0

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the logger level" do
      config = described_class.new

      expect(config.logger_level).to eq(Logger::DEBUG)
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.logger_level).to eq(Logger::INFO)
    end
  end
end
