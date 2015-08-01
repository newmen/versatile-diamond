module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Describes lateral reaction which creates by chunks combinations
    class CombinedLateralReaction
      include LateralReactionInstance
      extend Forwardable

      def_delegator :parent, :local?
      def_delegator :chunk, :sidepiece_specs
      attr_reader :chunk, :full_rate

      # Initializes combined lateral reaction
      # @param [DependentTypicalReaction] typical_reaction to which will be redirected
      #   calls for get source species and etc.
      # @param [MergedChunk] chunk which describes local environment of combined
      #   lateral reaction
      # @param [Float] full_rate of lateral reaction
      def initialize(typical_reaction, chunk, full_rate)
        @typical_reaction = typical_reaction
        @chunk = chunk
        @full_rate = full_rate

        @_adopted_source = nil
      end

      # Gets the internal typical reaction as parent of current reaction
      # @return [DependentTypicalReaction] the internal typical reaction
      def parent
        @typical_reaction
      end

      # Combined lateral reaction could not have children reactions
      # @return [Array] the empty array
      def children
        []
      end

      # Gets iterator of source specs
      # @yield [Concepts::Spec | Concepts::SpecificSpec] do for each reactant
      # @return [Enumerator] if block is not given
      def each_source(&block)
        typical_source = parent.each_source.to_a
        targets = chunk.targets
        if typical_source.size == targets.size
          targets.map(&:first).each(&block)
        elsif typical_source.size > targets.size
          adopted_source.each(&block)
        elsif typical_source.size < targets.size
          raise 'Typical source specs number less than chunks targets number'
        end
      end

      # Stores current reaction as parent child
      def store_to_parent!
        @typical_reaction.store_child(self)
      end

      # Gets the name of lateral reaction
      # @return [String] the name of lateral reaction
      def name
        "combined #{parent.name} with #{chunk.tail_name} No#{chunk.object_id}"
      end

      def formula
        "#{parent.formula} | ..."
      end

      def to_s
        "(#{name}, [#{parent.name}])"
      end

      def inspect
        to_s
      end

    private

      # Adopts source of parent reaction to correspond species from chunk targets
      # @return [Array] the adopted source species list
      def adopted_source
        return @_adopted_source if @_adopted_source

        specs = chunk.targets.to_a.map(&:first)
        srcs = parent.each_source.to_a.map do |spec|
          specs.delete_one { |ts| spec.same?(ts) } || spec
        end

        raise 'Incorrec source adaptation' unless specs.empty?
        @_adopted_source = srcs
      end
    end

  end
end
