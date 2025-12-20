# frozen_string_literal: true

Rails.application.routes.draw do
  # This mounts the web dashboard. It is recommended to add authentication around it.
  mount Ductwork::Engine, at: "/ductwork"
  # Add your own routes here, or remove this file if you don't have need for it.
end
