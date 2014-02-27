require 'spec_helper'

describe Alephant::Publisher::Writer do
  before(:each) do
    Alephant::Publisher::RenderMapper
      .any_instance
      .stub(:initialize)

      Alephant::Cache
        .any_instance
        .stub(:initialize)
  end

  subject do
    Alephant::Publisher::Writer.new({
      :renderer_id       => 'renderer_id',
      :lookup_table_name => 'lookup_table_name'
    })
  end

  describe "#write(data, version)" do
    before(:each) do
      Alephant::Publisher::RenderMapper
        .any_instance
        .stub(:generate)
        .and_return({
          'component_id' => Struct.new(:render).new('content')
        })

    end

    it "should write the correct lookup location" do
      options = { :key     => :value  }
      data    = { :options => options }

      Alephant::Cache.any_instance
        .stub(:put)

      Alephant::Lookup
        .should_receive(:create)
        .with('lookup_table_name')
        .and_call_original

      Alephant::Lookup::LookupHelper.any_instance
        .stub(:initialize)

      Alephant::Lookup::LookupTable
        .any_instance
        .stub(:table_name)

      Alephant::Lookup::LookupHelper.any_instance
        .should_receive(:batch_write)
        .with(
          'component_id',
          options,
          'renderer_id/component_id/42de5e5c6f74b9fe4d956704a6d9e1c7/0'
        )

      Alephant::Lookup::LookupHelper.any_instance
        .should_receive(:process!)

      subject.write(data, 0)
    end

    it "should put the correct location, content to cache" do
      Alephant::Lookup::LookupHelper
        .any_instance
        .stub(:initialize)

      Alephant::Lookup::LookupHelper
        .any_instance
        .stub(:batch_write)

      Alephant::Lookup::LookupHelper
        .any_instance
        .stub(:process!)

      Alephant::Lookup::LookupTable
        .any_instance
        .stub(:table_name)

      Alephant::Cache.any_instance
        .should_receive(:put)
        .with('renderer_id/component_id/35589a1cc0b3ca90fc52d0e711c0c434/0', 'content')

      subject.write({}, 0)
    end
  end
end
