# frozen_string_literal: true

require "ductwork/cli"

RSpec.describe Ductwork::CLI do
  it "parses arguments, loads configuration, and starts the worker launcher" do
    logger = instance_double(Logger, :level= => nil)
    config = instance_double(
      Ductwork::Configuration,
      :logger= => nil,
      logger: logger,
      logger_level: 0,
      logger_source: "default"
    )
    allow(Ductwork::Processes::SupervisorRunner).to receive(:start!)
    allow(Ductwork::Configuration).to receive(:new).and_return(config)

    described_class.start!([])

    expect(logger).to have_received(:level=).with(0)
    expect(config).to have_received(:logger=).with(Ductwork::Configuration::DEFAULT_LOGGER)
    expect(Ductwork::Configuration).to have_received(:new)
    expect(Ductwork::Processes::SupervisorRunner).to have_received(:start!)
  end
end
