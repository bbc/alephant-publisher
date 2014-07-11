require 'spec_helper'

describe Alephant::Publisher do
  let(:options)  { Alephant::Publisher::Options.new }
  let(:instance) { Alephant::Publisher.create(options) }

  before(:each) do
    allow_any_instance_of(Alephant::Publisher::SQSHelper::Queue).to receive(:initialize)
  end

  describe "#initialize(opts = {}, logger)" do
    it "sets parser, sequencer, queue and writer" do
      queue_double = double('AWS::SQS::QueueCollection', :named => 'test-queue')
      sqs_double = double('AWS::SQS', :queues => queue_double)

      expect(AWS::SQS).to receive(:new).and_return(sqs_double)
      expect(instance.queue).to be_a Alephant::Publisher::SQSHelper::Queue
    end
  end
end
