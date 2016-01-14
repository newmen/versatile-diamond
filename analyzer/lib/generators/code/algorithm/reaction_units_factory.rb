module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction find algorithm units
        class ReactionUnitsFactory < BaseReactionUnitsFactory

          # Initializes reaction find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction for which the algorithm is building
          def initialize(generator, reaction)
            super(generator)
            @reaction = reaction
            @used_reactants = Set.new
          end

          # Gets the reaction creator unit
          # @return [Units::ReactionCreatorUnit] the unit for defines reaction creation
          #   code block
          def creator
            creator_args = [@reaction, @used_reactants.to_a]
            Units::ReactionCreatorUnit.new(*default_args, *creator_args)
          end

        private

          # Gets the role of creating mono unit
          # @return [Module] the scope of methods which defines behavior of unit
          def behavior_role
            Units::ReactantBehavior
          end

          # Gets the object which provides global links
          # @return [TypicalReaction] reaction which should be found by building
          #   algorigm
          def relations_checker
            @reaction
          end

          # Stores the passed specie to internal collection
          # @param [Instances::SpecieInstance] uniq_reactant which will be stored
          def remember_uniq_specie(uniq_reactant)
            @used_reactants << uniq_reactant
          end
        end

      end
    end
  end
end
