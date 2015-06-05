module VersatileDiamond
  module Organizers

    # Provides logic for side-chunk of lateral reaction
    class Chunk < BaseChunk
      include MinuendChunk
      include DrawableChunk
      include TailedChunk
      include TargetsProcessor
      extend Forwardable
      extend Collector

      collector_methods :parent
      def_delegator :lateral_reaction, :full_rate
      attr_reader :lateral_reaction, :targets, :links

      # Initializes the chunk by lateral reaction and it there objects
      # @param [DependentLateralReaction] lateral_reaction link to which will be
      #   remembered
      # @param [Array] theres the array of there objects the links from which will be
      #   collected and used as links of chunk
      def initialize(lateral_reaction, theres)
        super()

        @lateral_reaction = lateral_reaction
        @theres = theres

        @targets = merge_targets(theres)
        @links = merge_links(theres)

        @_mapped_targets, @_tail_name = nil
      end

      # Gets the parent typical reaction
      # @return [DependentTypicalReaction] the parent typical reaction
      def typical_reaction
        lateral_reaction.parent
      end

      # The chunk which created by user described lateral reaction is original
      # @return [Boolean] true
      def original?
        true
      end

      # Organizes dependencies of current chunk from another chunks from table. If
      # residual of current chunk in table is not fully matched then independent
      # chunks stores as parent of current chunk and extend passed array of independent
      # chunks if already is not presented in it.
      #
      # @param [ChunksTable] table from which the best residual will be gotten
      # @param [Array] independent_chunks the list of independent chunks which gotten
      #   for another chunks
      # @return [Array] the possible extendend array of independent_chunks
      def organize_dependencies!(table, independent_chunks)
        best = table.best(self)
        best.parents.each { |parent| store_parent(parent) }

        unless best.fully_matched?
          ind_chunk = best.independent_chunk
          other_ind_chunk = independent_chunks.find { |ich| ind_chunk.same?(ich) }
          if other_ind_chunk
            store_parent(other_ind_chunk)
          else
            independent_chunks << ind_chunk
            store_parent(ind_chunk)
          end
        end

        independent_chunks
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

      # Gets the list of descriptions of there objects
      # @return [Array] the list of tail names
      def tail_names
        @theres.map(&:description)
      end

      # Provides the lowest level of comparing two minuend instances
      # @param [MinuendChunk] other comparing instance
      # @return [Proc] the core of comparison
      def comparing_core(other)
        if self.class == other.class
          -> { 0 }
        else
          -> { -1 }
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
