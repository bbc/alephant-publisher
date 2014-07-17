require 'alephant/publisher/views/base'
require 'json'

module Alephant
  module Publisher
    module Views
      class Json
        include ::Alephant::Publisher::Views::Base

        def setup
          @content_type = "application/json"
        end

        def render
          JSON.generate(to_h)
        end

      end
    end
  end
end
