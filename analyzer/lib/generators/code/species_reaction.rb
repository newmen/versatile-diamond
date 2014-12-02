module VersatileDiamond
  module Generators
    module Code

      # Provides generation logic for reation which uses species
      # @abstract
      class SpeciesReaction < BaseReaction
        include SpeciesUser
        extend Forwardable

        ANCHOR_SPECIE_NAME = 'target'

        def_delegators :reaction, :links, :clean_links, :relation_between, :changes

      protected

        def_delegator :reaction, :lateral?

      private

        # Gets the list of complex species which using as source of reaction
        # @reaturn [Array] the list of complex specie code generators
        def complex_source_species
          reaction.surface_source.uniq(&:name).map(&method(:specie_class))
        end
      end

    end
  end
end
