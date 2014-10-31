module VersatileDiamond
  module Generators
    module Code

      # Provides logic for reation generators which uses species code generators
      # @abstract
      class ReactionWithComplexSpecies < BaseReaction
        include SpeciesUser

      private

        # Gets the list of complex species which using as source of reaction
        # @reaturn [Array] the list of complex specie code generators
        def complex_source_species
          reaction.source.reject(&:simple?).uniq.map(&method(:specie_class))
        end
      end

    end
  end
end
