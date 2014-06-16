require_relative 'env'

require 'alephant/publisher/version'
require 'alephant/publisher/options'
require 'alephant/publisher/sqs_helper/queue'
require 'alephant/publisher/sqs_helper/archiver'
require 'alephant/publisher/writer'
require 'alephant/logger'
require 'alephant/support/aop'

module Alephant
  module Publisher
    include Logger
    extend Alephant::Support::AOP

    def self.create(opts = {})
      Publisher.new(opts)
    end

    class Publisher
      VISIBILITY_TIMEOUT = 60
      RECEIVE_WAIT_TIME  = 15

      attr_reader :queue, :executor, :opts

      def initialize(opts)
        @opts = opts

        @queue = SQSHelper::Queue.new(
          aws_queue,
          archiver,
          opts.queue[:visibility_timeout] || VISIBILITY_TIMEOUT,
          opts.queue[:receive_wait_time]  || RECEIVE_WAIT_TIME,
        )
      end

      def run!
        loop { process(@queue.message) }
      end

      private

      def archiver
        SQSHelper::Archiver.new(archive_cache)
      end

      def archive_cache
        Cache.new(
          opts.writer[:s3_bucket_id],
          opts.writer[:s3_object_path]
        )
      end

      def aws_queue
        AWS::SQS.new.queues[opts.queue[:sqs_queue_url]]
      end

      def write(msg)
        Writer.new(opts.writer, msg).run!
      end

      def process(msg)
        unless msg.nil?
          write msg
          msg.delete
        end
      end

    end
  end
end

