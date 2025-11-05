# frozen_string_literal: true

RSpec.describe Ductwork::Processes::PipelineAdvancer do
  describe "#call" do
    let(:running_context) { Ductwork::RunningContext.new }
    let(:klasses) { %w[MyPipeline] }

    it "completes steps in 'advancing' status" do
      advancing_step = create(:step, status: :advancing)
      _in_progress_step = create(:step, status: :in_progress)

      expect do
        described_class.new(running_context, *klasses).call
      end.to change { advancing_step.reload.status }.to("completed")
    end
  end
end
