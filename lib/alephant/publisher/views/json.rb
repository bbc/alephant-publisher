require 'alephant/publisher/views/base'
require 'json'

module Alephant::Publisher::Views
  class Json
    include Base

    def setup
      @content_type = "application/json"
    end

    def render
      JSON.generate(to_h)
    end

  end
end

