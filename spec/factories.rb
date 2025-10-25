# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :pipeline, class: "Ductwork::Pipeline" do
    sequence(:klass) { |n| "MyPipeline#{n}" }
    triggered_at { Time.current }
    definition { JSON.dump({}) }
    definition_sha1 { Digest::SHA1.hexdigest(definition) }
    status { Ductwork::Pipeline.statuses.keys.sample }
  end

  factory :step, class: "Ductwork::Step" do
    klass { "MyFirstJob" }
    started_at { Time.current }
    status { Ductwork::Step.statuses.keys.sample }
    step_type { Ductwork::Step.step_types.keys.sample }
    pipeline
  end
end
