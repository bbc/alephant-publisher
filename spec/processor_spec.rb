require 'spec_helper'

describe Alephant::Publisher::Processor do

  before(:each) do
    allow_any_instance_of(Alephant::Publisher::Writer).to receive(:initialize)
    allow_any_instance_of(Alephant::Publisher::Writer).to receive(:run!)
  end

  describe "#consume(msg)" do
    it "Consume the message and deletes it" do

      msg = double('AWS::SQS::ReceivedMessage', :delete => nil)
      expect(msg).to receive(:delete)
      subject.consume(msg)

    end
  end
end
