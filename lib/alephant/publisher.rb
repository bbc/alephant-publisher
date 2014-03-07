require_relative 'env'

require 'java'

# setup executor
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.Callable'

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
      attr_reader :queue

      def initialize(opts, logger)
        ::Alephant::Logger.set_logger(logger) unless logger.nil?

        @opts = opts
        @queue = Queue.new(
          opts[:sqs_queue_url]
        )
      end

      def run!
        core_pool_size    = @opts[:renderer_pool_min_size] || 2
        maximum_pool_size = @opts[:renderer_pool_max_size] || 4
        keep_alive_time   = @opts[:render_keep_alive_time] || 300

        executor = ThreadPoolExecutor.new(
          core_pool_size,
          maximum_pool_size,
          keep_alive_time,
          TimeUnit::SECONDS,
          LinkedBlockingQueue.new
        )

        @queue.poll do |msg|
          task = FutureTask.new(PublishTask.new(@opts, msg))
          executor.execute(task)
        end

        executor.shutdown()
      end

    end

    class PublishTask
      include Callable

      attr_reader :writer, :msg

      def initialize(opts,msg)
        @msg = msg
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

      def call
        writer.write(msg)
      end

    end
  end
end
