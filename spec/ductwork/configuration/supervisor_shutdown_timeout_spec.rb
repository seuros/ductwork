# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#supervisor_shutdown_timeout" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          supervisor:
            shutdown_timeout: 2

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the timeout" do
      config = described_class.new

      expect(config.supervisor_shutdown_timeout).to eq(2)
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.supervisor_shutdown_timeout).to eq(
        described_class::DEFAULT_SUPERVISOR_SHUTDOWN_TIMEOUT
      )
    end
  end
end
