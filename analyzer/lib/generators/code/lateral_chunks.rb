module VersatileDiamond
  module Generators
    module Code

      # Contains logic for description of common graph of all possible chunks of some
      # typical reaction
      class LateralChunks
        extend Forwardable

        def_delegators :total_chunk, :total_links, :clean_links

        # Initializes meta object which provides useful methods for code generators
        # @param [TypicalReaction] reaction from which the chunks of children lateral
        #   reactions will be wrapped
        # @param [Array] all_chunks of children lateral reactions of passed reaction
        # @param [Array] root_chunks of children lateral reactions of passed reaction
        def initialize(reaction, all_chunks, root_chunks)
          @reaction = reaction
          @all_chunks = all_chunks
          @root_chunks = root_chunks

          @total_chunk = Organizers::TotalChunk.new(reaction, all_chunks)
        end

      private

        attr_reader :total_chunk

      end
    end
  end
end
