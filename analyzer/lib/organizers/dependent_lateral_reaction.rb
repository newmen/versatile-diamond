module VersatileDiamond
  module Organizers

    # Wraps structural reaction with lateral interactions
    class DependentLateralReaction < DependentSpecReaction
      include LateralReactionInstance

      # Initializes dependent lateral reation
      # @override
      def initialize(*)
        super
        @_theres, @_chunk = nil
      end

      # Collects and return all used sidepiece specs
      # @return [Array] the array of sidepiece specs
      def sidepiece_specs
        reaction.theres.flat_map(&:env_specs)
      end

      # Gets the chunk which builded for current lateral reaction
      # @return [Chunk] the chunk which fully describes lateral environment
      def chunk
        @_chunk ||= Chunk.new(self, theres)
      end

      # Gets the list of dependent there objects. The internal caching is significant!
      # @return [Array] the list of dependent there objects
      def theres
        @_theres ||= reaction.theres.map { |th| DependentThere.new(self, th) }
      end

      # Gets the list of spec-atoms which are targets for sidepiece species
      # @return [Array] the list spec-atoms which are sidepiece targets
      def lateral_targets
        theres.map(&:targets).reduce(:+).to_a
      end

      # Also swap targets of depending chunk
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] from
      #   the spec from which need to swap
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] to
      #   the spec to which need to swap
      # @override
      def swap_source(from, to)
        super
        chunk.swap_spec(from, to) if @_chunk
      end

    private

      # Clears internal caches
      def clear_caches!
        super
        raise 'Chunk already created with possible swapping values' if @_chunk
      end
    end

  end
end
