require_relative 'env'

require 'alephant/publisher/version'
require 'alephant/publisher/options'
require 'alephant/logger'
require 'alephant/publisher/processor/queue_based'
require 'alephant/publisher/views'
require 'alephant/publisher/views/base'
require 'json'

module Alephant
  module Publisher
    include Logger

    def self.create(processor)
      raise ArgumentError, "No processor given." unless processor
      Publisher.new processor
    end

    class Publisher
      attr_reader :processor

      def initialize(processor)
        @processor = processor
      end

      def run!
        loop { processor.consume }
      end
    end
  end
end
