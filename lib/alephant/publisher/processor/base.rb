module Alephant
  module Publisher
    class BaseProcessor

      def consume(msg)
        raise NotImplementedError.new("You must implement the #consume(msg) method")
      end

    end
  end
end
