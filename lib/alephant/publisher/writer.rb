require 'peach'
require 'crimp'

require 'alephant/cache'
require 'alephant/views'
require 'alephant/renderer'
require 'alephant/lookup'
require 'alephant/sequencer'

require 'alephant/support/parser'

require 'alephant/publisher/write_operation'
require 'alephant/publisher/render_mapper'
require 'alephant/publisher/render_mapper'

module Alephant
  module Publisher
    class Writer
      attr_reader
        :id, :seq_id, :options, :data,
        :opt_hash :config, :mapper, :renders,
        :parser, :cache, :batch, :msg

      def initialize(config, msg)
        @config = config

        @cache = Cache.new(
          config[:s3_bucket_id],
          config[:s3_object_path]
        )

        @parser = Support::Parser.new(
          config[:msg_vary_path]
        )

        @mapper = RenderMapper.new(
          config[:renderer_id],
          config[:view_path]
        )

        @id       = config[:renderer_id]
        @msg      = msg
        @data     = parser.parse(msg)
        @options  = @data[:options]
        @opt_hash = Crimp.signature(@options)
        @renders  = mapper.generate(@data)
        @batch    = (@renders.count > 1) ? seq_for(id, @options) : nil
        @seq_id   = Sequencer::Sequencer.sequence_id_from(msg)

        @lookup_table_name = config[:lookup_table_name]
      end

      def run!
        batch? ? batch.sequence(msg, &perform) : perform.call
      end

      private

      def batch?
        !batch.nil?
      end

      def seq_for(id, options)
        Sequencer.create(
          config[:table_name],
          seq_key_from(id, options),
          config[:id_path]
        )
      end

      def seq_key_from(ident,options)
        "#{ident}/#{Crimp.signature(options)}"
      end

      def perform
        Proc.new { renders.peach { |component_id, r| write(component_id, r) } }
      end

      def write(component_id, renderer)
        seq_for(component_id, options).sequence(msg) do |msg|
          store(component_id, renderer.render, location_for(component_id))
        end
      end

      def store(component_id, content, location)
        cache.put(location, content)
        lookup.write(component_id, options, seq_id, location)
      end

      def lookup
        Lookup.create(@lookup_table_name)
      end

      def location_for(component_id)
        "#{id}/#{component_id}/#{@opt_hash}/#{seq_id}"
      end

    end
  end
end
