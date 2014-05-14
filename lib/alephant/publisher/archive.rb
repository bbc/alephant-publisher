module Alephant
  module Publisher
    module SQSHelper
      class Archiver
        attr_reader :cache

        def initialize(cache)
          @cache = cache
        end

        def see(m)

          m
        end

      end
    end
  end
end
