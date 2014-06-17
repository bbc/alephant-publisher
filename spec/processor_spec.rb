require 'spec_helper'

describe Alephant::Publisher::Processor do

  before(:each) do
    Alephant::Publisher::Writer.any_instance.stub(:initialize)
    Alephant::Publisher::Writer.any_instance.stub(:run!)
  end

  describe "#consume(msg)" do
    it "Consume the message and deletes it" do

      msg = double('AWS::SQS::ReceivedMessage', :delete => nil)
      expect(msg).to receive(:delete)
      subject.consume(msg)

    end
  end
end
