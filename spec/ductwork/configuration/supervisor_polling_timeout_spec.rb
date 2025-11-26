# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#supervisor_polling_timeout" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          supervisor:
            polling_timeout: 2

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the timeout" do
      config = described_class.new

      expect(config.supervisor_polling_timeout).to eq(2)
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.supervisor_polling_timeout).to eq(
        described_class::DEFAULT_SUPERVISOR_POLLING_TIMEOUT
      )
    end
  end
end
