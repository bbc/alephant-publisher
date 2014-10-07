require_relative 'env'

require 'alephant/publisher/version'
require 'alephant/logger'
require 'alephant/publisher/queue_based'
require 'alephant/publisher/request_based'
require 'json'

module Alephant
  module Publisher
    include Logger

    def self.create(opts)
      case opts[:strategy]
      when "request"
        Alephant::Publisher::RequestBased.new opts
      when "queue"
        Alephant::Publisher::QueueBased.new opts
      else
        raise ArgumentError, "No strategy given"
      end
    end
  end
end
