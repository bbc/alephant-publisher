require_relative 'env'

require 'alephant/publisher/version'
require 'alephant/publisher/options'
require 'alephant/publisher/queue'
require 'alephant/publisher/writer'
require 'alephant/logger'

module Alephant
  module Publisher
    include Logger

    def self.create(opts = {})
      Publisher.new(opts)
    end

    class Publisher
      VISIBILITY_TIMEOUT = 60
      RECEIVE_WAIT_TIME  = 15

      attr_reader :queue, :executor

      def initialize(opts)
        @opts = opts

        @queue = Queue.new(
          opts.queue[:sqs_queue_url],
          opts.queue[:visibility_timeout] || VISIBILITY_TIMEOUT,
          opts.queue[:receive_wait_time]  || RECEIVE_WAIT_TIME,
        )
      end

      def run!
        loop { process(@queue.message) }
      end

      private

      def process(msg)
        unless msg.nil?
          Writer.new(@opts.writer, msg).run!
          msg.delete
        end
      end

    end
  end
end
