require_relative 'env'

require 'alephant/publisher/version'
require 'alephant/publisher/queue'
require 'alephant/publisher/writer'
require 'alephant/logger'

module Alephant
  module Publisher
    include ::Alephant::Logger

    def self.create(opts = {}, logger = nil)
      Publisher.new(opts, logger)
    end

    class Publisher
      VISIBILITY_TIMEOUT = 60
      RECEIVE_WAIT_TIME  = 15

      attr_reader :queue, :executor

      def initialize(opts, logger)
        ::Alephant::Logger.set_logger(logger) unless logger.nil?

        @opts = opts
        @queue = Queue.new(
          opts[:sqs_queue_url],
          opts[:visibility_timeout] || VISIBILITY_TIMEOUT,
          opts[:receive_wait_time]  || RECEIVE_WAIT_TIME,
        )

        @writer_opts = opts.select do |k,v|
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
      end

      def run!
        loop { process(@queue.message) }
      end

      private

      def process(msg)
        unless msg.nil?
          Writer.new(@writer_opts, msg).run!
          msg.delete
        end
      end

    end
  end
end
