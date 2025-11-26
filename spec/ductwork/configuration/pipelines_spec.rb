# frozen_string_literal: true

RSpec.describe Ductwork::Configuration, "#pipelines" do
  include ConfigurationFileHelper

  let(:data) do
    <<~DATA
      default: &default
        pipelines:
          - PipelineA
          - PipelineB

      development:
        <<: *default

      test:
        pipelines: "*"

      production:
        <<: *default
    DATA
  end
  let(:config_file) { create_temp_file }

  it "returns the pipelines from the config file at the given path" do
    rails = double(env: "development")
    stub_const("Rails", rails)

    config = described_class.new(path: config_file.path)

    expect(config.pipelines).to eq(%w[PipelineA PipelineB])
  end

  it "returns the pipelines from the default config file if no path given" do
    rails = double(env: "production")
    stub_const("Rails", rails)
    create_default_config_file

    config = described_class.new

    expect(config.pipelines).to eq(%w[PipelineA PipelineB])
  end

  it "returns all defined pipelines when wildcard is configured" do
    collection = %w[PipelineA PipelineB PipelineC]
    allow(Dir).to receive(:glob).and_return(collection)

    config = described_class.new(path: config_file.path)

    expect(config.pipelines).to eq(%w[PipelineA PipelineB PipelineC])
  end

  it "returns an empty collection when no config file exists" do
    config = described_class.new

    expect(config.pipelines).to be_empty
  end
end
