require 'alephant/publisher/writer'
require 'alephant/publisher/processor/base'

module Alephant
  module Publisher
    class Processor < BaseProcessor
      attr_reader :writer_config

      def initialize(writer_config = {})
        @writer_config = writer_config
      end

      def consume(msg)
        unless msg.nil?
          write msg
          msg.delete
        end
      end

      private

      def write(msg)
        Writer.new(writer_config, msg).run!
      end
    end
  end
end
