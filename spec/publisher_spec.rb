require 'spec_helper'

describe Alephant::Publisher do
  let(:options)       { Alephant::Publisher::Options.new }
  let(:queue)         { double('AWS::SQS::Queue', :url => nil ) }
  let(:queue_double)  { double('AWS::SQS::QueueCollection', :[] => queue, :url_for => nil) }
  let(:client_double) { double('AWS::SQS', :queues => queue_double) }

  before(:each) do
    expect(AWS::SQS).to receive(:new).and_return(client_double)
  end

  describe ".create" do
    it "sets parser, sequencer, queue and writer" do
      instance = Alephant::Publisher.create(options)
      expect(instance.queue).to be_a Alephant::Publisher::SQSHelper::Queue
    end

    context "with account" do
      it "creates a queue with an account number in the option hash" do
        options = Alephant::Publisher::Options.new
        options.add_queue({ :sqs_queue_name => 'bar', :aws_account_id => 'foo' })

        expect(queue_double).to receive(:url_for).with('bar', { :queue_owner_aws_account_id => 'foo' })

        Alephant::Publisher.create(options)
      end
    end

    context "without account" do
      it "creates a queue with an empty option hash" do
        options = Alephant::Publisher::Options.new
        options.add_queue({ :sqs_queue_name => 'bar' })

        expect(queue_double).to receive(:url_for).with('bar', {})

        Alephant::Publisher.create(options)
      end
    end
  end
end
