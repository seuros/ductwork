# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#job_worker_max_retry" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          job_worker:
            max_retry: 5

        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the timeout" do
      config = described_class.new

      expect(config.job_worker_max_retry).to eq(5)
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.job_worker_max_retry).to eq(
        described_class::DEFAULT_JOB_WORKER_MAX_RETRY
      )
    end
  end
end
