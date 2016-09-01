module VersatileDiamond
  module Organizers

    # Provides logic for typical chunk
    # @abstract
    class TypicalChunk < BaseChunk
      include ChunkParentsOrganizer
      include DrawableChunk
      extend Forwardable
      extend Collector

      collector_methods :parent
      def_delegator :lateral_reaction, :full_rate
      attr_reader :lateral_reaction, :targets, :links, :tail_name

      # Initializes the typical chunk
      # @param [DependentLateralReaction] lateral_reaction link to which will be
      #   remembered
      # @param [Set] targets of new chunk
      # @param [Hash] links of new chunk
      # @param [String] tail_name of new chunk
      def initialize(lateral_reaction, targets, links, tail_name)
        super(targets, links)
        @lateral_reaction = lateral_reaction
        @tail_name = tail_name

        @_internal_chunks, @_total_links_num = nil
      end

      # Gets fake name for strong ordering and tests farm
      # @return [Symbol]
      # @override
      def name
        underscorize = -> nm { nm.gsub(' ', '_') }
        fixed_env_description = underscorize[tail_name]
        if typical_reaction
          fixed_reaction_name = underscorize[typical_reaction.name]
          :"__typical_chunk_of_#{fixed_reaction_name}_with_#{fixed_env_description}"
        else
          :"__typical_chunk__with_#{fixed_env_description}"
        end
      end

      # Gets the parent typical reaction
      # @return [DependentTypicalReaction] the parent typical reaction
      def typical_reaction
        lateral_reaction.parent
      end

      def to_s
        name
      end

      def inspect
        to_s
      end

    private

      # Gets class of new replacing target instance
      # @return [Class] of new instance
      def replace_class
        TargetReplacedChunk
      end

      # Gets the list of attributes which will passed to constructor of new instance
      # @param [Set] new_targets of creating instance
      # @param [Hasn] new_links of creating instance
      # @return [Array] the list of constructor arguments
      def replace_instance_args(new_targets, new_links)
        [lateral_reaction, new_targets, new_links, "target replaced #{tail_name}"]
      end
    end

  end
end
