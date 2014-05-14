module Alephant
  module Publisher
    module SQSHelper
      class Archiver
        attr_reader :cache

        def initialize(cache)
          @cache = cache
        end

        def see(message)
          return if message.nil?

          message.tap do |m|
            cache.put(
              "archive/#{m.id}",
              m.body,
              message_meta_for(m)
            )
          end
        end

        private

        def message_meta_for(m)
          {
            :id                => m.id,
            :md5               => m.md5,
            :logged_at         => Time.now.to_s,
            :queue             => m.queue.url,
          }
        end
      end
    end
  end
end
