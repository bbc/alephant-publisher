require 'alephant/publisher/writer'
require 'alephant/publisher/processor'
require 'alephant/publisher/sqs_helper/queue'
require 'alephant/publisher/sqs_helper/archiver'

module Alephant
  module Publisher
    class QueueBasedProcessor < Processor
      VISIBILITY_TIMEOUT = 60
      RECEIVE_WAIT_TIME  = 15

      attr_reader :opts, :queue

      def initialize(opts = {})
        @opts = opts
        @queue = SQSHelper::Queue.new(
          aws_queue,
          archiver,
          opts.queue[:visibility_timeout] || VISIBILITY_TIMEOUT,
          opts.queue[:receive_wait_time]  || RECEIVE_WAIT_TIME,
        )
      end

      def consume
        msg = @queue.message
        unless msg.nil?
          write msg
          msg.delete
        end
      end

      def write(msg)
        Writer.new(opts.writer, msg).run!
      end

      private

      def archiver
        SQSHelper::Archiver.new archive_cache
      end

      def archive_cache
        Cache.new(
          opts.writer[:s3_bucket_id],
          opts.writer[:s3_object_path]
        )
      end

      def aws_queue
        queue_url = sqs_client.queues.url_for(opts.queue[:sqs_queue_name], sqs_queue_options)
        sqs_client.queues[queue_url]
      end

      def sqs_client
        @sqs_client ||= AWS::SQS.new
      end

      def sqs_queue_options
        opts.queue[:aws_account_id].nil? ? {} : { :queue_owner_aws_account_id => opts.queue[:aws_account_id] }
      end
    end
  end
end
