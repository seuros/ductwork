# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#job_worker_shutdown_timeout" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          job_worker:
            shutdown_timeout: 30

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the timeout" do
      config = described_class.new

      expect(config.job_worker_shutdown_timeout).to eq(30)
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.job_worker_shutdown_timeout).to eq(
        described_class::DEFAULT_JOB_WORKER_SHUTDOWN_TIMEOUT
      )
    end
  end
end
