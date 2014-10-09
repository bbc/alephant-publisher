require 'spec_helper'

describe Alephant::Publisher::Writer do
  let(:opts) do
    {
      :lookup_table_name    => 'lookup_table_name',
      :msg_vary_id_path     => '$.vary',
      :renderer_id          => :renderer_id,
      :s3_bucket_id         => :s3_bucket_id,
      :s3_object_path       => :s3_object_path,
      :sequence_id_path     => '$.sequence',
      :sequencer_table_name => :sequencer_table_name,
      :view_path            => :view_path
    }
  end

  before(:each) do
    AWS.stub!

    allow_any_instance_of(Alephant::Cache).to receive(:initialize)
      .with(
        opts[:s3_bucket_id],
        opts[:s3_object_path]
      )

    allow_any_instance_of(Alephant::Sequencer::SequenceTable).to receive(:create)

    allow_any_instance_of(Alephant::Sequencer::Sequencer).to receive(:sequencer_id_from)
      .and_return(1)

    allow_any_instance_of(Alephant::Sequencer::Sequencer).to receive(:set_last_seen)

    allow_any_instance_of(Alephant::Sequencer::Sequencer).to receive(:get_last_seen)

    allow_any_instance_of(Alephant::Lookup::LookupTable).to receive(:create)

    allow_any_instance_of(Alephant::Lookup::LookupTable).to receive(:table_name)

    allow_any_instance_of(Alephant::Renderer::Renderer).to receive(:views).and_return({})
  end

  describe "#run!" do
    let(:msg) do
      data = {
        "sequence" => "1",
        "vary" => "foo"
      }
      Struct.new(:body,:id).new(data.to_json,'id')
    end

    let(:expected_location) do
      'renderer_id/component_id/218c835cec343537589dbf1619532e4d/1'
    end

    let(:renderer) do
      instance_double 'Alephant::Renderer::Renderer'
    end

    subject do
      Alephant::Publisher::Writer.new(opts, msg)
    end

    it "should write the correct lookup location" do
      allow_any_instance_of(Alephant::Cache).to receive(:put)

      allow_any_instance_of(Alephant::Lookup::LookupHelper).to receive(:write)
        .with(
          "component_id",
          {:variant=>"foo"},
          1,
          expected_location
        )
    end

    it "should put the correct location, content to cache" do
      allow_any_instance_of(Alephant::Lookup::LookupHelper).to receive(:write)

      allow_any_instance_of(Alephant::Cache).to receive(:put)
        .with(expected_location, "content", "foo/bar", :msg_id=>"id")
    end

    after do
      subject.run!
    end
  end
end
