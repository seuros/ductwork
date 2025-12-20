# frozen_string_literal: true

Ductwork::Engine.routes.draw do
  root "dashboards#show", as: :dashboard

  resources :pipelines, only: %w[index show]
  resources :step_errors, only: %w[index]
end
