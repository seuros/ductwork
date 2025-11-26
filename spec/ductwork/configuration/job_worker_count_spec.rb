# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#job_worker_count" do
  include ConfigurationFileHelper

  context "with a count for all pipelines" do
    let(:data) do
      <<~DATA
        default: &default
          job_worker:
            count: 5

        test:
          <<: *default
      DATA
    end

    it "returns the count" do
      create_default_config_file

      config = described_class.new

      expect(config.job_worker_count("foobar")).to eq(5)
    end

    it "returns the manually set value" do
      create_default_config_file
      config = described_class.new
      config.job_worker_count = 1_000

      expect(config.job_worker_count("foo")).to eq(1_000)
    end
  end

  context "with a count for the specific pipeline" do
    let(:data) do
      <<~DATA
        default: &default
          job_worker:
            count:
              PipelineA: 5
              PipelineB: 10

        test:
          <<: *default
      DATA
    end

    it "returns the count" do
      create_default_config_file

      config = described_class.new

      expect(config.job_worker_count("PipelineB")).to eq(10)
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.job_worker_count("foobar")).to eq(
        described_class::DEFAULT_JOB_WORKER_COUNT
      )
    end
  end
end
