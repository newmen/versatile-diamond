module VersatileDiamond
  module Organizers

    # Wraps structural reaction with lateral interactions
    class DependentLateralReaction < DependentSpecReaction

      def_delegator :reaction, :theres

      # Initializes dependent lateral reation
      # @override
      def initialize(*)
        super
        @_theres = nil
      end

      # Collects and return all used sidepiece specs
      # @return [Array] the array of sidepiece specs
      def sidepiece_specs
        reaction.theres.flat_map(&:env_specs)
      end

      # Gets the list of dependent there objects. The internal caching is significant!
      # @return [Array] the list of dependent there objects
      def theres
        @_theres ||= reaction.theres.map { |th| DependentThere.new(self, th) }
      end

      # Checks that current reaction covered by other reaction
      # @param [DependentLateralReaction] other the comparable reaction
      # @return [Boolean] covered or not
      def cover?(other)
        super_same?(other) && other.theres.all? do |there|
          theres.any? { |t| t.cover?(there) }
        end
      end

      # Lateral reaction is lateral reaction
      # @return [Boolean] true
      def lateral?
        true
      end

      # Organize dependencies from another lateral reactions
      # @param [Array] lateral_reactions the possible children
      def organize_dependencies!(lateral_reactions)
        lateral_reactions.each do |possible|
          possible.store_parent(self) if self != possible && possible.cover?(self)
        end
      end

    private

      # Calls the #same? method from superclass or internal reaction instance
      # @param [DependentLateralReaction] other the comparable lateral reaction
      # @return [Boolean] same by super or not
      def super_same?(other)
        super_method = reaction.class.superclass.instance_method(:same?).bind(reaction)
        super_method.call(other.reaction)
      end
    end

  end
end
