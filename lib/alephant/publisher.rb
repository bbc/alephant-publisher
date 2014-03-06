require_relative 'env'

require 'alephant/logger'

require "alephant/publisher/version"
require 'alephant/publisher/models/writer'
require 'alephant/publisher/models/queue'

module Alephant
  module Publisher
    include ::Alephant::Logger

    def self.create(opts = {}, logger = nil)
      Publisher.new(opts, logger)
    end

    private

    class Publisher
      attr_reader :sequencer, :queue, :writer

      def initialize(opts, logger)
        ::Alephant::Logger.set_logger(logger) unless logger.nil?

        @queue = Queue.new(
          opts[:sqs_queue_url]
        )

        @writer = Writer.new(
          opts.select do |k,v|
            [
              :msg_vary_id_path,
              :sequencer_table_name,
              :sequence_id_path,
              :renderer_id,
              :s3_bucket_id,
              :s3_object_path,
              :view_path,
              :lookup_table_name
            ].include? k
          end
        )
      end

      def run!
        Thread.new do
          @queue.poll { |msg| writer.write(msg) }
        end
      end

    end
  end
end
