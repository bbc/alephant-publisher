require 'peach'
require 'crimp'

require 'alephant/cache'
require 'alephant/views'
require 'alephant/renderer'
require 'alephant/lookup'
require 'alephant/logger'
require 'alephant/sequencer'
require 'alephant/support/parser'
require 'alephant/publisher/render_mapper'

module Alephant
  module Publisher
    class Writer
      include ::Alephant::Logger
      attr_reader :config, :message, :cache, :parser, :mapper

      def initialize(config, message)
        @config   = config
        @message  = message

        @cache = Cache.new(
          config[:s3_bucket_id],
          config[:s3_object_path]
        )

        @parser = Support::Parser.new(
          config[:message_vary_path]
        )

        @mapper = RenderMapper.new(
          config[:renderer_id],
          config[:view_path]
        )
      end

      def run!
        batch? ? batch.sequence(message, &perform) : perform.call
      end

      private

      def perform
        Proc.new { renders.peach { |id, r| write(id, r) } }
      end

      def write(id, r)
        begin
          seq_for(id).sequence(message) do
            store(id, r.render, location_for(id))
          end
        rescue Exception => e
          logger.warn "Alephant::Publisher::Writer#write: #{e.message}\n#{e.backtrace.join('\n')}"

          raise e
        end
      end

      def store(id, content, location)
        cache.put(location, content)
        lookup.write(id, options, seq_id, location)
      end

      def location_for(id)
        "#{config[:renderer_id]}/#{id}/#{opt_hash}/#{seq_id}"
      end

      def batch
        @batch ||= (renders.count > 1) ? seq_for(config[:renderer_id]) : nil
      end

      def batch?
        !batch.nil?
      end

      def seq_for(id)
        Sequencer.create(config[:sequencer_table_name], seq_key_from(id), config[:sequence_id_path])
      end

      def seq_key_from(id)
        "#{id}/#{opt_hash}"
      end

      def seq_id
        @seq_id ||= Sequencer::Sequencer.sequence_id_from(message, config[:msg_vary_id_path])
      end

      def renders
        @renders ||= mapper.generate(data)
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
        Lookup.create(config[:lookup_table_name])
      end
    end
  end
end
