module VersatileDiamond
  module Organizers

    # Wraps structural reaction with lateral interactions
    class DependentLateralReaction < DependentSpecReaction

      def_delegator :reaction, :theres

      # Collects and return all where object
      # @return [Array] the array of where objects
      def wheres
        theres.map(&:where)
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
          next if possible == self
          next unless reaction.cover?(possible.reaction)

          possible.store_parent(self)
        end
      end
    end

  end
end
