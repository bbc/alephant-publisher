require 'aws-sdk'
require 'alephant/logger'

module Alephant
  module Publisher
    class Queue
      WAIT_TIME = 5
      VISABILITY_TIMEOUT = 300

      include ::Alephant::Logger

      attr_reader :timeout, :wait_time
      attr_accessor :q

      def initialize(id, timeout = VISABILITY_TIMEOUT, wait_time = WAIT_TIME)
        @timeout = timeout
        @wait_time = wait_time
        @sqs = AWS::SQS.new
        @q = @sqs.queues[id]

        unless @q.exists?
          @q = @sqs.queues.create(id)
          sleep_until_queue_exists
          logger.info("Queue.initialize: created queue with id #{id}")
        end

        logger.info("Queue.initialize: ended with id #{id}")
      end

      def sleep_until_queue_exists
        sleep 1 until @q.exists?
      end

      def message
        @q.receive_message({
          :visibility_timeout => @timeout,
          :wait_time_seconds => @wait_time
        })
      end
    end
  end
end
