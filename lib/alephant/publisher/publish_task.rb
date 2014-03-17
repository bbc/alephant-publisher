require 'java'

java_import 'java.util.concurrent.Callable'

require 'alephant/publisher/writer'

module Alephant
  module Publisher
    class PublishTask
      include Callable

      attr_reader :opts, :message

      def initialize(opts, message)
        @message = message
        @opts = opts
      end

      def call
        unless message.nil?
          Writer.new(opts, message).run!
          message.delete
        end
      end

    end
  end
end

