module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a lateral reaction which was found
        class ReactionLookAroundCreatorUnit < BaseReactionCreatorUnit

          # Gets the cpp code string with creation of lateral reaction
          # @return [String] the cpp code line with creation lateral reaction call
          def lines
            alloc_str = "new #{reaction.class_name}(this, #{name_of(species)})"
            code_line("chunks[index++] = #{alloc_str};")
          end
        end

      end
    end
  end
end
