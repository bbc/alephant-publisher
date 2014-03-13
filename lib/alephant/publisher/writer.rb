require 'alephant/cache'
require 'alephant/views'
require 'alephant/renderer'
require 'alephant/lookup'

require 'alephant/publisher/write_operation'
require 'alephant/publisher/render_mapper'

module Alephant
  module Publisher
    class Writer
      attr_reader :mapper, :cache

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

        @renderer_id = opts[:renderer_id]

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
        component_sequencer = write_op.sequencer_for(component_id, write_op.options)

        component_sequencer.sequence(write_op.msg) do |msg|
          store(component_id, renderer.render, write_op.options, location)
        end
      end

      def store(component_id, content, options, location)
        cache.put(location, content)
        lookup_for(component_id).write(options, location)
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
end
