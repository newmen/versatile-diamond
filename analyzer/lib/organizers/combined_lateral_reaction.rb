module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Describes lateral reaction which creates by chunks combinations
    class CombinedLateralReaction
      class PseudoReaction
        attr_reader :full_rate

        def initialize(full_rate, rate_tuple)
          @full_rate = full_rate
          @rate_tuple = rate_tuple
        end

        def method_missing(name)
          @rate_tuple.fetch(name)
        end
      end

      extend Forwardable

      def_delegators :parent, :local?, :source
      def_delegator :chunk, :sidepiece_specs
      def_delegator :reaction, :full_rate
      attr_reader :chunk, :reaction

      # Initializes combined lateral reaction
      # @param [DependentTypicalReaction] typical_reaction to which will be redirected
      #   calls for get source species and etc.
      # @param [MergedChunk] chunk which describes local environment of combined
      #   lateral reaction
      # @param [Float] full_rate of lateral reaction
      # @param [Hash] rate_tuple of lateral reaction
      def initialize(typical_reaction, chunk, full_rate, rate_tuple)
        @typical_reaction = typical_reaction
        @chunk = chunk
        @reaction = PseudoReaction.new(full_rate, rate_tuple)

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
      # @param [Symbol] target the type of iterating species
      # @yield [Concepts::Spec | Concepts::SpecificSpec] do for each reactant
      # @return [Enumerator] if block is not given
      def each(target, &block)
        typical_target_specs = parent.each(target).to_a
        if target == :source
          if typical_target_specs.size < chunk.targets.size
            raise 'Typical source specs number less than chunks targets number'
          else
            (adopted_source + chunk.sidepiece_specs.to_a).each(&block)
          end
        else
          typical_target_specs.each(&block)
        end
      end

      # Stores current reaction as parent child
      def store_to_parent!
        @typical_reaction.store_child(self)
      end

      # Combined lateral reaction is lateral reaction
      # @return [Boolean] true
      def lateral?
        true
      end

      # Gets the name of lateral reaction
      # @return [String] the name of lateral reaction
      def name
        "combined #{parent.name} with #{chunk.tail_name}"
      end

      def formula
        "#{parent.formula} | ..."
      end

      def to_s
        "(#{name} No#{chunk.object_id}, [#{parent.to_s}])"
      end

      def inspect
        to_s
      end

    private

      # Adopts source of parent reaction to correspond species from chunk targets
      # @return [Array] the adopted source species list
      def adopted_source
        return @_adopted_source if @_adopted_source

        specs = chunk.target_specs.to_a
        srcs = parent.each(:source).map do |spec|
          specs.delete_one { |ts| spec.same?(ts) } || spec
        end

        raise 'Incorrec source adaptation' unless specs.empty?
        @_adopted_source = srcs
      end
    end

  end
end
