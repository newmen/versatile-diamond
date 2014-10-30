module VersatileDiamond
  module Generators
    module Code

      # Provides logic for reation generators which uses species code generators
      # @abstract
      class ReactionWithComplexSpecies < BaseReaction
        include SpeciesUser
      end

    end
  end
end
