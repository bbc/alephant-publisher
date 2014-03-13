require 'crimp'

require 'alephant/sequencer'
require 'alephant/support/parser'

module Alephant
  module Publisher
    class WriteOperation
      attr_reader :msg, :data, :options, :options_hash, :version, :batch_sequencer

      def initialize(msg, opts)
        @msg                = msg
        @data               = Support::Parser.new(opts[:msg_vary_path]).parse(msg)
        @options            = @data[:options]
        @options_hash       = Crimp.signature(@options)
        @renderer_id        = opts[:renderer_id]
        @sequencer_opts     = opts[:sequencer_opts]
        @batch_sequencer    = sequencer_for(@renderer_id, @options)
        @version            = @batch_sequencer.sequence_id_from(msg)
      end

      def sequencer_for(id, options)
        Sequencer.create(
          @sequencer_opts[:table_name],
          sequencer_id_from(id, options),
          @sequencer_opts[:id_path]
        )
      end

      private

      def sequencer_id_from(id,options)
        "#{id}/#{Crimp.signature(options)}"
      end

    end
  end
end

