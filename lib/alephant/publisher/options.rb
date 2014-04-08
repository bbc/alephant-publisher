require 'aws-sdk'
require 'alephant/logger'

module Alephant
  module Publisher
    class InvalidKeySpecifiedError < StandardError; end

    class Options
      attr_reader :queue, :writer

      QUEUE_OPTS = [
        :sqs_queue_url,
        :visibility_timeout,
        :receive_wait_time
      ]

      WRITER_OPTS = [
        :msg_vary_id_path,
        :sequencer_table_name,
        :sequence_id_path,
        :renderer_id,
        :s3_bucket_id,
        :s3_object_path,
        :view_path,
        :lookup_table_name
      ]

      def initialize
        @queue  = {}
        @writer = {}
      end

      def add_queue(opts)
        execute @queue, QUEUE_OPTS, opts
      end

      def add_writer(opts)
        execute @writer, WRITER_OPTS, opts
      end

      private

      def execute(instance, type, opts)
        begin
          validate type, opts
          instance.merge! opts
        rescue Exception => e
          puts e.message
        end
      end

      def validate(type, opts)
        opts.each do |key, value|
          raise InvalidKeySpecifiedError, "The key '#{key}' is invalid" unless type.include? key.to_sym
        end
      end
    end
  end
end
