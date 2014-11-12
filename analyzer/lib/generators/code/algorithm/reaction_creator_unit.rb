module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a reaction which was found
        class ReactionCreatorUnit < BaseCreatorUnit

          # Gets the code lines for reaction creation
          # @return [String] the lines by which the reaction will be created
          def lines
            if target_species.size == 1
              create_call
            else
            end
          end

        private

          alias :reaction :original_target
          alias :target_species :defined_species

          # Gets the cpp code string with creation of target reaction
          # @return [String] the cpp code line with creation target reaction call
          def create_call
            species_var_name = namer.name_of(target_species)
            code_line("create<#{reaction.class_name}>(#{species_var_name});")
          end
        end

      end
    end
  end
end
