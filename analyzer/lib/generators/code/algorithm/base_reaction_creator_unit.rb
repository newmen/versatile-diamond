module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create an instance which was found
        # @abstract
        class BaseReactionCreatorUnit
          include CommonCppExpressions
          include AtomCppExpressions

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [BaseReaction] reaction which uses in current building algorithm
          # @param [Array] species the list of all previously defined unique species
          def initialize(namer, reaction, species)
            @namer = namer
            @reaction = reaction
            @species = reaction.order_species(species)
          end

        private

          attr_reader :namer, :reaction, :species

        end

      end
    end
  end
end
