# frozen_string_literal: true

RSpec.describe Ductwork::Context do
  let(:pipeline_id) { create(:pipeline).id }

  describe "#get" do
    subject(:context) { described_class.new(pipeline_id) }

    it "returns nil if the key does not exist" do
      value = context.get("foobar")

      expect(value).to be_nil
    end

    it "returns the value for the key" do
      Ductwork::Tuple.create!(
        key: "key",
        value: "value",
        pipeline_id: pipeline_id,
        first_set_at: Time.current,
        last_set_at: Time.current
      )

      value = context.get("key")

      expect(value).to eq("value")
    end

    it "only returns values for the specific pipeline" do
      Ductwork::Tuple.create!(
        key: "key",
        value: "value",
        pipeline_id: create(:pipeline).id,
        first_set_at: Time.current,
        last_set_at: Time.current
      )

      value = context.get("key")

      expect(value).to be_nil
    end

    it "raises if the key is not a string" do
      expect do
        context.get(1)
      end.to raise_error(ArgumentError, "Key must be a string")
    end
  end

  describe "#set" do
    subject(:context) { described_class.new(pipeline_id) }

    it "sets the value for the given key" do
      context.set("key", "value")

      expect(context.get("key")).to eq("value")
    end

    it "returns the given value" do
      value = context.set("key", "value")

      expect(value).to eq("value")
    end

    it "creates a tuple record" do
      expect do
        context.set("key", "value")
      end.to change(Ductwork::Tuple, :count).by(1)

      tuple = Ductwork::Tuple.sole
      expect(tuple.pipeline_id).to eq(pipeline_id)
      expect(tuple.key).to eq("key")
      expect(tuple.value).to eq("value")
      expect(tuple.first_set_at).to be_within(1.second).of(Time.current)
      expect(tuple.last_set_at).to be_within(1.second).of(Time.current)
    end

    it "raises if trying to overwrite value" do
      context.set("key", "value")

      expect do
        context.set("key", "value")
      end.to raise_error(described_class::OverwriteError, "Can only set value once")
    end

    it "overwrites the value if explicitly passed the argument" do
      context.set("key", 1)

      context.set("key", 2, overwrite: true)
      value = context.get("key")

      expect(value).to eq(2)
    end
  end
end
