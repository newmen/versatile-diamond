module VersatileDiamond
  module Generators
    module Code

      # Contains logic for description of common graph of all possible chunks of some
      # typical reaction
      class LateralChunks < Organizers::BaseChunk
        include Modules::GraphDupper

        # Initializes meta object which provides useful methods for code generators
        # @param [TypicalReaction] reaction from which the chunks of children lateral
        #   reactions will be wrapped
        # @param [Array] all_chunks of children lateral reactions of passed reaction
        # @param [Array] root_chunks of children lateral reactions of passed reaction
        def initialize(reaction, all_chunks, root_chunks)
          @reaction = reaction
          @all_chunks = all_chunks
          @root_chunks = root_chunks

          @_total_links, @_clean_links = nil
        end

        # Gets total links of all participants
        # @return [Hash] the graph of of relations between all using specs and their
        #   atoms
        def total_links
          @_total_links ||=
            @all_chunks.reduce(dup_graph(@reaction.links)) do |acc, chunk|
              adsorb_links(chunk.targets, acc, chunk.links)
            end
        end

        # Gets clean links which contains just relations between reactants and
        # sidepiece species
        def clean_links
          @_clean_links ||= @all_chunks.reduce({}) do |acc, chunk|
            adsorb_links(chunk.targets, acc, chunk.clean_links)
          end
        end

      private

        # Adsorbs all adsorbing links and gets total links
        # @param [Set] targets from which the edges cannot be duplicated
        # @param [Hash] original_links which will be extended in result
        # @param [Hash] adsorbing_links which will extend the original links
        # @return [Hash] the extended original links
        def adsorb_links(targets, original_links, adsorbing_links)
          adsorbing_links.each_with_object(original_links) do |(spec_atom, rels), acc|
            if acc[spec_atom] && targets.include?(spec_atom)
              acc[spec_atom] += dup_rels(rels.reject { |sa, _| acc[sa] })
            elsif !acc[spec_atom]
              acc[spec_atom] = dup_rels(rels)
            end
          end
        end

        # Dups passed rels and all internal spec_atom pairs
        # @param [Array] rels which will be dupped
        # @return [Array] the dupped rels
        def dup_rels(rels)
          rels.map { |sa, r| [sa.dup, r] }
        end
      end
    end
  end
end
