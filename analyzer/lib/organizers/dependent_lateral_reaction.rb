module VersatileDiamond
  module Organizers

    # Wraps structural reaction with lateral interactions
    class DependentLateralReaction < DependentReaction

      # Wraps each there object to correspond dependent instance
      # @return [Array] the array of wrapped there objects
      def theres
        reaction.theres.map { |there| DependentThere.new(there) }
      end
    end

  end
end
