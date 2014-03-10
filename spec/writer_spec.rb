require 'spec_helper'

describe Alephant::Publisher::Writer do
  let(:opts) do
    {
      :s3_bucket_id => :s3_bucket_id,
      :s3_object_path => :s3_object_path,
      :renderer_id => :renderer_id,
      :view_path => :view_path,
      :lookup_table_name => 'lookup_table_name',
      :sequencer_table_name => :sequencer_table_name,
      :sequence_id_path => '$.sequence',
      :msg_vary_id_path => '$.vary',
    }
  end

  before(:each) do
    AWS.stub!

    Alephant::Publisher::RenderMapper
      .any_instance
      .should_receive(:initialize)
      .with(
        opts[:renderer_id],
        opts[:view_path]
      )

    Alephant::Cache
      .any_instance
      .should_receive(:initialize)
      .with(
        opts[:s3_bucket_id],
        opts[:s3_object_path]
      )

    Alephant::Sequencer::SequenceTable
      .any_instance
      .stub(:create)

    Alephant::Sequencer::Sequencer
      .any_instance
      .stub(:sequencer_id_from)
      .and_return(1)

    Alephant::Sequencer::Sequencer
      .any_instance
      .stub(:set_last_seen)

    Alephant::Sequencer::Sequencer
      .any_instance
      .stub(:get_last_seen)

    Alephant::Lookup::LookupHelper
      .any_instance
      .stub(:create_lookup_table)

    Alephant::Lookup::LookupTable
      .any_instance
      .stub(:table_name)

    Alephant::Publisher::RenderMapper
      .any_instance
      .stub(:generate)
      .and_return({
        'component_id' => Struct.new(:render).new('content')
      })

  end

  subject do
    Alephant::Publisher::Writer.new(opts)
  end

  describe "#write(data, version)" do
    let(:msg) do
      data = {
        "sequence" => "1",
        "vary" => "foo"
      }
      Struct.new(:body).new(data.to_json)
    end

    let(:expected_location) do
      'renderer_id/component_id/218c835cec343537589dbf1619532e4d/1'
    end

    it "should write the correct lookup location" do
      Alephant::Cache.any_instance.stub(:put)

      Alephant::Lookup::LookupHelper
        .any_instance
        .should_receive(:write)
        .with(
          {:variant=>"foo"},
          expected_location
        )
    end

    it "should put the correct location, content to cache" do
      Alephant::Lookup::LookupHelper.any_instance.stub(:write)

      Alephant::Cache
        .any_instance
        .should_receive(:put)
        .with(expected_location, "content")
    end

    after do
      subject.write(msg)
    end
  end
end
