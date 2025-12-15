# frozen_string_literal: true

RSpec.describe Ductwork::Pipeline, "#advance" do
  subject(:pipeline) do
    create(:pipeline, status: :in_progress, definition: definition)
  end

  context "when the next step is 'combine'" do
    let(:definition) do
      {
        nodes: %w[MyStepA.0 MyStepB.1 MyStepC.1 MyStepD.2],
        edges: {
          "MyStepA.0" => { to: %w[MyStepB.1 MyStepC.1], type: "divide", klass: "MyStepA" },
          "MyStepB.1" => { to: %w[MyStepD.2], type: "combine", klass: "MyStepB" },
          "MyStepC.1" => { to: %w[MyStepD.2], type: "combine", klass: "MyStepC" },
          "MyStepD.2" => { klass: "MyStepD" },
        },
      }.to_json
    end
    let(:step) do
      create(
        :step,
        status: :advancing,
        node: "MyStepC.1",
        klass: "MyStepC",
        pipeline: pipeline
      )
    end
    let(:output_payload) { { payload: }.to_json }
    let(:payload) { %w[a b c] }

    before do
      # other step from the other branch of the `divide` action
      other_step = create(
        :step,
        status: :advancing,
        node: "MyStepB.1",
        klass: "MyStepB",
        pipeline: pipeline
      )
      create(:job, output_payload: output_payload, step: other_step)
      create(:job, output_payload:, step:)
    end

    it "creates a new step and enqueues a job" do
      expect do
        pipeline.advance!
      end.to change(Ductwork::Step, :count).by(1)
        .and change(Ductwork::Job, :count).by(1)
      step = Ductwork::Step.last
      expect(step).to be_in_progress
      expect(step.node).to eq("MyStepD.2")
      expect(step.klass).to eq("MyStepD")
      expect(step.to_transition).to eq("combine")
    end

    it "passes the output payload as input arguments to the next step" do
      allow(Ductwork::Job).to receive(:enqueue)

      pipeline.advance!

      expect(Ductwork::Job).to have_received(:enqueue).with(
        anything, [payload, payload]
      )
    end

    context "when the pipeline has been expanded then divided" do
      let(:advancing_steps) do
        [
          *create_list(
            :step,
            3,
            status: :advancing,
            to_transition: :combine,
            node: "MyStepC.2",
            klass: "MyStepC",
            pipeline: pipeline
          ),
          *create_list(
            :step,
            3,
            status: :advancing,
            to_transition: :combine,
            node: "MyStepD.2",
            klass: "MyStepD",
            pipeline: pipeline
          ),
          *create_list(
            :step,
            3,
            status: :advancing,
            to_transition: :combine,
            node: "MyStepE.2",
            klass: "MyStepE",
            pipeline: pipeline
          ),
        ]
      end
      let(:definition) do
        {
          nodes: %w[MyStepA MyStepB MyStepC MyStepD MyStepE MyStepF],
          edges: {
            "MyStepA.0" => { to: %w[MyStepB.1], type: "expand", klass: "MyStepA" },
            "MyStepB.1" => { to: %w[MyStepC.2 MyStepD.2 MyStepE.2], type: "divide", klass: "MyStepB" },
            "MyStepC.2" => { to: %w[MyStepF.3], type: "combine", klass: "MyStepC" },
            "MyStepD.2" => { to: %w[MyStepF.3], type: "combine", klass: "MyStepD" },
            "MyStepE.2" => { to: %w[MyStepF.3], type: "combine", klass: "MyStepE" },
            "MyStepF.3" => { klass: "MyStepF" },
          },
        }.to_json
      end

      before do
        # assume all previous steps have completed successfully
        Ductwork::Step.update!(status: "completed")
        advancing_steps.each do |s|
          create(:job, output_payload: output_payload, step: s)
        end
      end

      it "collapses each active branch" do
        expect do
          pipeline.advance!
        end.to change(Ductwork::Step, :count).by(3)
          .and change(Ductwork::Job, :count).by(3)
        klasses = Ductwork::Step.pluck(:klass).last(3)
        expect(klasses).to eq(%w[MyStepF MyStepF MyStepF])
      end
    end
  end
end
