require 'spec_helper'

describe Alephant::Publisher do
  let(:instance) { Alephant::Publisher.create }

  before(:each) do
    Alephant::Publisher::Writer.any_instance.stub(:initialize)
    Alephant::Publisher::Queue.any_instance.stub(:initialize)
    Alephant::Support::Parser.any_instance.stub(:initialize)
    Alephant::Sequencer::Sequencer.any_instance.stub(:initialize)
  end

  describe "#initialize(opts = {}, logger)" do
    it "sets parser, sequencer, queue and writer" do
      expect(instance.writer).to    be_a Alephant::Publisher::Writer
      expect(instance.queue).to     be_a Alephant::Publisher::Queue
      expect(instance.parser).to    be_a Alephant::Support::Parser
      expect(instance.sequencer).to be_a Alephant::Sequencer::Sequencer
    end
  end

  describe "#run!" do
    it "returns a Thread" do
      expect(instance.run!).to be_a(Thread)
    end

    it "calls @queue.poll" do
      instance.should_receive(:receive).with(:msg)

      expect_any_instance_of(Alephant::Publisher::Queue)
      .to receive(:poll)
      .and_yield(:msg)

      t = instance.run!
      t.join
    end
  end

  describe "#receive(msg)" do
    before(:each) do
      Alephant::Support::Parser
        .any_instance
        .stub(:parse)
        .and_return(:parsed_msg)

      Alephant::Sequencer::Sequencer
        .any_instance
        .stub(:sequence_id_from)
        .and_return(:sequence_id)

      Alephant::Sequencer::Sequencer
        .any_instance
        .stub(:set_last_seen)
    end

    context "message is nonsequential" do
      before(:each) do
        Alephant::Sequencer::Sequencer
          .any_instance
          .stub(:sequential?)
          .and_return(false)
      end

      it "should not call write" do
        Alephant::Publisher::Writer
          .any_instance
          .should_not_receive(:write)

        instance.receive(:msg)
      end
    end

    context "message is sequential" do
      before(:each) do
        Alephant::Sequencer::Sequencer
          .any_instance
          .stub(:sequential?)
          .and_return(true)
      end

      it "calls writer with a parsed message and sequence_id" do
        Alephant::Publisher::Writer
          .any_instance
          .should_receive(:write)
          .with(:parsed_msg, :sequence_id)

        instance.receive(:msg)
      end
    end
  end

end
