require 'spec_helper'

describe Alephant::Publisher::SQSHelper::Archiver do
  describe "#see" do
    it "calls cache put with the correct params" do
      time_now = DateTime.parse("Feb 24 1981")
      allow(DateTime).to receive(:now).and_return(time_now)

      q = double("queue").as_null_object
      c = double("cache").as_null_object

      expect(q).to receive(:url).and_return('url')

      m = Struct.new(:id, :body, :md5, :queue).new('id', 'body', 'md5', q)

      expect(c).to receive(:put).with(
        "archive/#{time_now.strftime('%d-%m-%Y_%H')}/id",
        "body",
        {
          :id        => "id",
          :md5       => "md5",
          :logged_at => time_now.to_s,
          :queue     => "url"
        }
      )

      instance = Alephant::Publisher::SQSHelper::Archiver.new(c, false)

      instance.see(m)
    end
  end
end

