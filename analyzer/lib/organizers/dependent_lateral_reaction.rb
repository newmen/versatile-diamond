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
        @_theres ||= reaction.theres.map { |th| DependentThere.new(th) }
      end

      # Provides where objects for graphs generators
      # @return [Array] the array of using where objects
      def wheres
        theres.map(&:where)
      end

      # Gets the list of spec-atoms which are targets for sidepiece species
      # @return [Array] the list spec-atoms which are sidepiece targets
      def lateral_targets
        theres.map(&:targets).reduce(:+).to_a
      end

    private

      # Compares two lateral reaction instances by there objects of them
      # @param [DependentLateralReaction] other comparable lateral reaction
      # @return [Integer] the result of comparison
      # @override
      def partial_order(other)
        order(self, other, :theres, :size) do
          theres.sort.zip(other.theres.sort).reduce(0) do |acc, (t1, t2)|
            acc == 0 ? (t1 <=> t2) : acc
          end
        end
      end
    end

  end
end
