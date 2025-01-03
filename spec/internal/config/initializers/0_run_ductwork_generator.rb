# frozen_string_literal: true

require "rails/generators"

# Simulate using the generator, most importantly to create migration files
Rails::Generators.invoke(
  "ductwork:install",
  [],
  destination_root: Combustion::Application.root.to_s
)
