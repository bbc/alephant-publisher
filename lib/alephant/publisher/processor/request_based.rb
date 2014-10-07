module Alephant
  module Publisher
    class RequestBasedProcessor < Processor
      attr_reader :opts

      def initialize(component_name, hash, opts = {})
        @opts = opts
      end

      def consume
      end

      private


    end
  end
end
