# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#pipeline_polling_timeout" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          pipeline_advancer:
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

      expect(config.pipeline_polling_timeout).to eq(2)
    end

    it "returns the manually set value" do
      config = described_class.new

      config.pipeline_polling_timeout = 0.5

      expect(config.pipeline_polling_timeout).to eq(0.5)
    end

    context "with pipeline-level configuration" do
      let(:data) do
        <<~DATA
          default: &default
            pipeline_advancer:
              polling_timeout:
                default: 2
                MyPipelineA: 3

          test:
            <<: *default
        DATA
      end

      it "returns the configured value" do
        config = described_class.new

        expect(config.pipeline_polling_timeout("MyPipelineA")).to eq(3)
      end

      it "returns the base default if no pipeline configuration" do
        config = described_class.new

        expect(config.pipeline_polling_timeout("MyPipelineB")).to eq(2)
      end
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.pipeline_polling_timeout).to eq(
        described_class::DEFAULT_PIPELINE_POLLING_TIMEOUT
      )
    end
  end
end
