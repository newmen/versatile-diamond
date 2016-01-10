module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create an instance which was found
        # @abstract
        class BaseReactionCreatorUnit < GenerableUnit
          # Initializes the creator
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [BaseReaction] reaction which uses in current building algorithm
          # @param [Array] species the list of all previously defined unique species
          def initialize(generator, namer, reaction, species)
            super(generator, namer)
            @reaction = reaction
            @species = reaction.order_species(species)
          end

        private

          attr_reader :reaction, :species

        end

      end
    end
  end
end
