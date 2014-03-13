require_relative 'env'

require 'java'

java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.FutureTask'

require 'alephant/publisher/version'
require 'alephant/publisher/queue'
require 'alephant/publisher/publish_task'
require 'alephant/logger'

module Alephant
  module Publisher
    include ::Alephant::Logger

    def self.create(opts = {}, logger = nil)
      Publisher.new(opts, logger)
    end

    class Publisher

      VISIBILITY_TIMEOUT = 300
      KEEP_ALIVE_TIMEOUT = 300
      RECEIVE_WAIT_TIME  = 15
      POOL_MIN_SIZE      = 2
      POOL_MAX_SIZE      = 4

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

        @executor = ThreadPoolExecutor.new(
          @opts[:renderer_pool_min_size] || POOL_MIN_SIZE,
          @opts[:renderer_pool_max_size] || POOL_MAX_SIZE,
          @opts[:render_keep_alive_time] || KEEP_ALIVE_TIMEOUT,
          TimeUnit::SECONDS,
          LinkedBlockingQueue.new
        )
      end

      def run!
        while true
          executor.execute(
            FutureTask.new(
              PublishTask.new(
                @writer_opts,
                @queue.message
              )
            )
          )
        end

        executor.shutdown()
      end
    end
  end
end
