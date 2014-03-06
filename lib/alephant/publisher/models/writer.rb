require 'crimp'

require 'alephant/sequencer'
require 'alephant/support/parser'

module Alephant
  module Publisher
    class Writer
      attr_reader :mapper, :cache, :parser

      def initialize(opts)
        @cache = Cache.new(
          opts[:s3_bucket_id],
          opts[:s3_object_path]
        )

        @mapper = RenderMapper.new(
          opts[:renderer_id],
          opts[:view_path]
        )

        @lookup_table_name = opts[:lookup_table_name]

        @write_opts = {
          :sequencer_opts => {
            :table_name => opts[:sequencer_table_name],
            :id_path    => opts[:sequence_id_path]
          },
          :msg_vary_path => opts[:msg_vary_id_path],
          :renderer_id => opts[:renderer_id]
        }
      end

      def write(msg)
        write_op = WriteOperation.new(msg, @write_opts)

        write_op.batch_sequencer.sequence(msg) do |msg|
          mapper.generate(write_op.data).each do |component_id, renderer|
            write_component(write_op, component_id, renderer)
          end
        end
      end

      private
      def write_component(write_op, component_id, renderer)
        location = location_for(component_id, write_op.options, write_op.version)
        sequencer_id = write_op.sequencer_id_from(component_id,write_op.options)
        component_sequencer = write_op.sequencer_for(sequencer_id)

        component_sequencer.sequencer(write_op.msg) do |msg|
          cache.put(location, renderer.render)
          lookup_for(component_id).write(write_op.options, location)
        end
      end

      def lookup_for(id)
        Lookup.create(@lookup_table_name, id)
      end

      def location_for(component_id, options, version = nil)
        options_hash = Crimp.signature(options)
        base_name = "#{@renderer_id}/#{component_id}/#{options_hash}"
        version ? "#{base_name}/#{version}" : base_name
      end

    end
  end

  class WriteOperation
    attr_reader :message, :data, :options, :options_hash, :version, :batch_sequencer

    def initialize(msg, opts)
      @msg = msg
      @data = Support::Parser.new(opts[:msg_vary_path]).parse(msg)
      @options = @data[:options]
      @options_hash = Crimp.signature(@options)
      @renderer_id = opts[:renderer_id]
      @sequencer_opts = opts[:sequencer_opts]
      @batch_sequencer_id = "#{@renderer_id}/#{@options_hash}"
      @batch_sequencer = sequencer_for(@batch_sequencer_id)
      @version = @batch_sequencer.sequence_id_from(@msg)
    end

    def sequencer_id_from(id,options)
      "#{id}/#{Crimp.signature(options)}"
    end

    def sequencer_for(sequence_id)
      Sequencer.create(
        @sequencer_opts[:table_name],
        sequence_id,
        @sequencer_opts[:id_path]
      )
    end
  end
end
