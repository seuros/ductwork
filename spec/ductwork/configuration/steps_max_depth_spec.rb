# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#steps_max_depth" do
  include ConfigurationFileHelper

  context "when the config file exists" do
    let(:data) do
      <<~DATA
        default: &default
          pipeline_advancer:
            steps:
              max_depth: 42
        test:
          <<: *default
      DATA
    end

    before do
      create_default_config_file
    end

    it "returns the top-level configured max depth" do
      config = described_class.new

      expect(config.steps_max_depth).to eq(42)
    end

    it "returns the top-level configured max depth if no pipeline config" do
      config = described_class.new

      max_depth = config.steps_max_depth(pipeline: "MyPipelineA")

      expect(max_depth).to eq(42)
    end

    it "returns the manually set value" do
      config = described_class.new
      config.steps_max_depth = 5

      pipeline_max_depth = config.steps_max_depth(pipeline: "MyPipelineA")
      max_depth = config.steps_max_depth

      expect(pipeline_max_depth).to eq(5)
      expect(max_depth).to eq(5)
    end

    context "when there is pipeline-level configuration" do
      let(:data) do
        <<~DATA
          default: &default
            pipeline_advancer:
              steps:
                max_depth:
                  default: 42
                  MyPipelineA: 1_000
          test:
            <<: *default
        DATA
      end

      it "returns the pipeline-level configuration" do
        config = described_class.new

        max_depth = config.steps_max_depth(pipeline: "MyPipelineA")

        expect(max_depth).to eq(1_000)
      end

      it "returns the default pipeline-level configuration" do
        config = described_class.new

        max_depth = config.steps_max_depth

        expect(max_depth).to eq(42)
      end

      it "returns the default pipeline-level configuration if no pipeline config" do
        config = described_class.new

        max_depth = config.steps_max_depth(pipeline: "MyPipelineB")

        expect(max_depth).to eq(42)
      end

      context "when there is no pipeline-level default" do
        let(:data) do
          <<~DATA
            default: &default
              pipeline_advancer:
                steps:
                  max_depth:
                    MyPipelineA: 1_000
            test:
              <<: *default
          DATA
        end

        it "returns the base default" do
          config = described_class.new

          max_depth = config.steps_max_depth

          expect(max_depth).to eq(described_class::DEFAULT_STEPS_MAX_DEPTH)
        end
      end
    end

    context "when there is step-level configuration" do
      let(:data) do
        <<~DATA
          default: &default
            pipeline_advancer:
              steps:
                max_depth:
                  MyPipelineA:
                    default: 42
                    MyStepA: 15_250
          test:
            <<: *default
        DATA
      end

      it "returns the step-level configuration" do
        config = described_class.new

        max = config.steps_max_depth(pipeline: "MyPipelineA", step: "MyStepA")

        expect(max).to eq(15_250)
      end

      it "returns the pipeline-level default configuration" do
        config = described_class.new

        max = config.steps_max_depth(pipeline: "MyPipelineA", step: "MyStepB")

        expect(max).to eq(42)
      end

      it "returns the base default" do
        config = described_class.new

        max = config.steps_max_depth(pipeline: "MyPipelineB", step: "MyStepA")

        expect(max).to eq(described_class::DEFAULT_STEPS_MAX_DEPTH)
      end
    end
  end

  context "when no config file exists" do
    it "returns the default" do
      config = described_class.new

      expect(config.steps_max_depth).to eq(
        described_class::DEFAULT_STEPS_MAX_DEPTH
      )
    end
  end
end
