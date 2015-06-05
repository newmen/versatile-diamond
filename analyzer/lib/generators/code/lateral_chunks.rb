module VersatileDiamond
  module Generators
    module Code

      # Contains logic for description of all possible chunks of some typical reaction
      class LateralChunks
        include Modules::GraphDupper

        # Initializes meta object which provides useful methods for code generators
        # @param [TypicalReaction] reaction from which the chunks of children lateral
        #   reactions will be wrapped
        # @param [Array] chunks of children lateral reactions of passed reaction
        def initialize(reaction, chunks)
          @reaction = reaction
          @chunks = chunks

          @_total_links, @_clean_links = nil
        end

        # Gets total links of all participants
        # @return [Hash] the graph of of relations between all using specs and their
        #   atoms
        def total_links
          @_total_links ||= @chunks.reduce(dup_graph(@reaction.links)) do |acc, chunk|
            adsorb_links(acc, chunk.links)
          end
        end

        # Gets clean links which contains just relations between reactants and
        # sidepiece species
        def clean_links
          @_clean_links ||= chunks.reduce({}) do |acc, chunk|
            adsorb_links(acc, chunk.clean_links)
          end
        end

      private

        # Adsorbs all adsorbing links and gets total links
        # @param [Hash] original_links which will be extended in result
        # @param [Hash] adsorbing_links which will extend the original links
        # @return [Hash] the extended original links
        def adsorb_links(original_links, adsorbing_links)
          adsorbing_links.each_with_object(original_links) do |(spec_atom, rels), acc|
            acc[spec_atom] ||= []
            acc[spec_atom] += rels.map { |sa, r| [sa.dup, r] }
          end
        end
      end
    end
  end
end
