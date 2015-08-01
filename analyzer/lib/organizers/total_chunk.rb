module VersatileDiamond
  module Organizers

    # Describes the chunk which constructs from another chunks and can substract
    # another chunks from self
    class TotalChunk < BaseChunk
      include Modules::GraphDupper
      include MinuendChunk

      attr_reader :typical_reaction

      # Initializes the total chunk by target typical reaction and chunks which are
      # parts of this
      #
      # @param [DependentTypicalReaction] typical_reaction the target of passed chunks
      # @param [Array] chunks the list of parts of creating total chunk
      def initialize(typical_reaction, chunks)
        super(merge_targets(chunks), merge_links(chunks))
        @typical_reaction = typical_reaction

        @_total_links = nil
      end

      # Gets total links of all participants
      # @return [Hash] the graph of of relations between all using specs and atoms
      def total_links
        @_total_links ||=
          adsorb_links(targets, dup_graph(@typical_reaction.links), links)
      end

    private

      # Gets self chunk
      # @return [TotalChunk] self
      def owner
        self
      end

      # Gets set of targets from all passed containers
      # @param [Array] chunks the list of chunks which targets will be merged
      # @return [Set] the set of targets of internal chunks
      def merge_targets(chunks)
        ChunkTargetsMerger.new.merge(chunks)
      end

      # Merges all links from chunks list
      # @param [Array] chunks which links will be merged
      # @return [Hash] the common links hash
      def merge_links(chunks)
        chunks.reduce({}) do |acc, chunk|
          adsorb_links(chunk.targets, acc, chunk.links)
        end
      end

      # Adsorbs all adsorbing links and gets total links
      # @param [Set] targets from which the edges cannot be duplicated
      # @param [Hash] original_links which will be extended in result
      # @param [Hash] adsorbing_links which will extend the original links
      # @return [Hash] the extended original links
      def adsorb_links(targets, original_links, adsorbing_links)
        adsorbing_links.each_with_object(original_links) do |(spec_atom, rels), acc|
          if acc[spec_atom] && targets.include?(spec_atom)
            new_rels = rels.reject do |sa, _|
              acc[spec_atom].any? { |x, _| sa == x }
            end
            acc[spec_atom] += dup_rels(new_rels)
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
