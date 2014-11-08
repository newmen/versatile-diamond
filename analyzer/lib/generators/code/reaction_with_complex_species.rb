module VersatileDiamond
  module Generators
    module Code

      # Provides logic for reation generators which uses species code generators
      # @abstract
      class ReactionWithComplexSpecies < BaseReaction
        include SpeciesUser
        extend Forwardable

        def_delegators :reaction, :original_links, :clean_links, :relation_between

      protected

        def_delegator :reaction, :lateral?

      private

        # Gets the list of complex species which using as source of reaction
        # @reaturn [Array] the list of complex specie code generators
        def complex_source_species
          reaction.surface_source.map(&method(:specie_class))
        end
      end

    end
  end
end
