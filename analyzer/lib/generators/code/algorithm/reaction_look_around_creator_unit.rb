module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a lateral reaction which was found
        class ReactionLookAroundCreatorUnit < SingleLateralReactionCreatorUnit
          include LateralSpecDefiner

          # Gets the cpp code string with creation of lateral reaction
          # @return [String] the cpp code line with creation lateral reaction call
          def lines
            value = alloc_str('this')
            code_line("chunks[index++] = #{value};")
          end

        private

          # Gets list of sidepiece species which will passed to creating lateral
          # reaction
          #
          # @return [Array] the list of sidepiece species
          def sidepiece_species
            different_species
          end
        end

      end
    end
  end
end
