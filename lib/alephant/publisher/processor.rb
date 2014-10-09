require 'alephant/publisher/writer'
require 'alephant/publisher/processor/base'
require 'alephant/renderer'

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

      def write(msg)
        renderer = Alephant::Renderer.create(writer_config, msg)
        Writer.new(writer_config, msg, renderer).run!
      end

    end
  end
end
