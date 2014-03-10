require 'spec_helper'

describe Alephant::Publisher do
  let(:instance) { Alephant::Publisher.create }

  before(:each) do
    Alephant::Publisher::Queue.any_instance.stub(:initialize)
  end

  describe "#initialize(opts = {}, logger)" do
    it "sets parser, sequencer, queue and writer" do
      expect(instance.queue).to     be_a Alephant::Publisher::Queue
    end
  end

  describe "#run!" do
    it "calls @queue.poll" do
      expect_any_instance_of(Alephant::Publisher::Queue)
      .to receive(:poll)
      .and_yield(:msg)

      t = instance.run!
    end
  end
end

describe Alephant::Publisher::PublishTask do
  before(:each) do
    Alephant::Publisher::PublishTask.any_instance
      .stub(:initialize)
  end

  it { should respond_to(:call) }

end
