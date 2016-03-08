require "peach"
require "crimp"

require "alephant/cache"
require "alephant/lookup"
require "alephant/logger"
require "alephant/sequencer"
require "alephant/support/parser"
require "alephant/publisher/view_mapper"

module Alephant
  module Publisher
    class Writer
      include Logger

      attr_reader :config, :message, :cache, :parser, :mapper

      def initialize(config, message)
        @config   = config
        @message  = message
      end

      def mapper
        @mapper ||= ViewMapper.new(
          config[:renderer_id],
          config[:view_path]
        )
      end

      def cache
        Cache.new(
          config[:s3_bucket_id],
          config[:s3_object_path]
        )
      end

      def parser
        @parser ||= Support::Parser.new(
          config[:msg_vary_id_path]
        )
      end

      def run!
        batch? ? batch.validate(message, &perform) : perform.call
      end

      protected

      def perform
        Proc.new { views.each { |id, view| write(id, view) } }
      end

      def write(id, view)
        seq_for(id).validate(message) do
          store(id, view, location_for(id))
        end
      end

      def store(id, view, location)
        cache.put(location, view.render, view.content_type, :msg_id => message.id)
        lookup.write(id, options, seq_id, location)
      end

      def location_for(id)
        "#{config[:renderer_id]}/#{id}/#{opt_hash}/#{seq_id}"
      end

      def batch
        @batch ||= (views.count > 1) ? seq_for(config[:renderer_id]) : nil
      end

      def batch?
        !batch.nil?
      end

      def seq_for(id)
        Sequencer.create(
          config[:sequencer_table_name],
          {
            :id => seq_key_from(id),
            :jsonpath => config[:sequence_id_path],
            :keep_all => config[:keep_all_messages] == "true"
          }
        )
      end

      def seq_key_from(id)
        "#{id}/#{opt_hash}"
      end

      def seq_id
        @seq_id ||= Sequencer::Sequencer.sequence_id_from(message, config[:sequence_id_path])
      end

      def views
        @views ||= mapper.generate(data)
      end

      def opt_hash
        @opt_hash ||= Crimp.signature(options)
      end

      def options
        @options ||= data[:options]
      end

      def data
        @data ||= parser.parse(message)
      end

      def lookup
        Lookup.create(config[:lookup_table_name], config)
      end
    end
  end
end
