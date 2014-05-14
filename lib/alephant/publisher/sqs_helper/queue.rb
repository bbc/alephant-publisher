require 'aws-sdk'
require 'alephant/logger'

module Alephant
  module Publisher
    module SQSHelper
      class Queue
        WAIT_TIME = 5
        VISABILITY_TIMEOUT = 300

        include Logger

        attr_reader :queue, :timeout, :wait_time, :archiver

        def initialize(queue, archiver, timeout = VISABILITY_TIMEOUT, wait_time = WAIT_TIME)
          @queue     = queue
          @archiver  = archiver
          @timeout   = timeout
          @wait_time = wait_time

          logger.info("Queue#initialize: reading from #{queue.url}")
        end

        def message
          recieve.tap do |m|
            unless m.nil? do
              logger.info("Queue#message: received #{m.id}")
              archive m
            end
          end
        end

        def archive(m)
          archiver.see(m)
        end

        def recieve
          queue.receive_message({
            :visibility_timeout => timeout,
            :wait_time_seconds  => wait_time
          })
        end
      end
    end
  end
end

