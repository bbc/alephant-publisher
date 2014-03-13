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

end

describe Alephant::Publisher::PublishTask do
  before(:each) do
    Alephant::Publisher::PublishTask.any_instance
      .stub(:initialize)
  end

  it { should respond_to(:call) }

end
