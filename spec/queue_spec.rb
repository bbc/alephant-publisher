require 'spec_helper'

describe Alephant::Publisher::SQSHelper::Queue do
  describe "#message" do
    it "returns a message" do
      m = double("message").as_null_object
      q = double("queue").as_null_object

      expect(q).to receive(:receive_message).and_return(m)

      instance = Alephant::Publisher::SQSHelper::Queue.new(q)

      expect(instance.message).to eq(m)
    end

    it "call see(m) on the handed archiver" do
      a = double("archiver").as_null_object
      m = double("message").as_null_object
      q = double("queue").as_null_object

      expect(q).to receive(:receive_message).and_return(m)
      expect(a).to receive(:see).with(m)

      instance = Alephant::Publisher::SQSHelper::Queue.new(q, a)

      expect(instance.message).to eq(m)
    end
  end
end

