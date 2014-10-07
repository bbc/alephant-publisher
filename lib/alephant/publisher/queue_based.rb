require 'alephant/publisher/processor/queue_based'

module Alephant
  module Publisher
    class QueueBased
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
