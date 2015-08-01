module VersatileDiamond
  module Organizers

    # Provides logic for side-chunk of lateral reaction
    class Chunk < TypicalChunk
      include Modules::SpecAtomSwapper
      include MinuendChunk

      # Initializes the chunk by lateral reaction and it there objects
      # @param [DependentLateralReaction] lateral_reaction link to which will be
      #   remembered
      # @param [Array] theres the array of there objects the links from which will be
      #   collected and used as links of chunk
      def initialize(lateral_reaction, theres)
        tail_name = theres.map(&:description).join(' and ')
        super(lateral_reaction, merge_targets(theres), merge_links(theres), tail_name)
      end

      # Also swap targets and links of current chunk
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] from
      #   the spec from which need to swap
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] to
      #   the spec to which need to swap
      def swap_spec(from, to)
        @targets = targets.map { |spec_atom| swap(spec_atom, from, to) }.to_set
        @links = swap_in_links(:swap, links, from, to)
      end

      # The chunk which created by user described lateral reaction is original
      # @return [Boolean] true
      def original?
        true
      end

      def inspect
        "Chunk of #{tail_name}"
      end

    private

      # Gets set of targets from all passed there objects
      # @param [Array] theres which targets will be merged
      # @return [Set] the set of merged targets
      def merge_targets(theres)
        theres.map(&:targets).reduce(:+)
      end

      # Adsorbs all links from there objects
      # @param [Array] theres which links will be merged
      # @return [Hash] the common links hash
      def merge_links(theres)
        theres.each_with_object({}) do |there, acc|
          there.links.each do |sa1, rels|
            acc[sa1] ||= []
            acc[sa1] += rels
          end
        end
      end

      # Gets the self instance
      # @return [Chunk] self
      def owner
        self
      end
    end

  end
end
