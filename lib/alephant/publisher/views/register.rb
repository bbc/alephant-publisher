require 'alephant/publisher/views'
require 'json'
require 'hashie'

module Alephant::Publisher::Views
  module Register
    attr_accessor :data

    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def initialize(data = {})
        @data = Hashie::Mash.new data

        setup
      end

      def setup; end
    end

    module ClassMethods
      def inherited(subclass)
        current_dir = File.dirname(caller.first[/^[^:]+/])
        dir_path    = Pathname.new(File.join(current_dir,'..')).realdirpath

        subclass.base_path = dir_path.to_s

        Alephant::Publisher::Views.register(subclass)
      end
    end
  end
end

