module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a lateral reaction which was found
        class ReactionLookAroundCreatorUnit < BaseReactionCreatorUnit

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [LateralReaction] reaction which will created by current algorithm
          # @param [Array] species the list of all previously defined unique species
          def initialize(namer, reaction, species)
            super(namer, species)
            @reaction = reaction
          end

          # Gets the cpp code string with creation of lateral reaction
          # @return [String] the cpp code line with creation lateral reaction call
          def lines
            value = alloc_str('this')
            code_line("chunks[index++] = #{value};")
          end

        private

          # Gets the string with memory allocation of lateral reaction
          # @param [String] parent_var_name the name of variable of parent reaction
          # @return [String] the cpp code string
          def alloc_str(parent_var_name)
            args_str = creating_args(parent_var_name).join(', ')
            "new #{creating_class}(#{args_str})"
          end

          # Gets the class name of creating instance
          # @return [String] the name of creating instance class
          def creating_class
            @reaction.class_name
          end

          # String values which will passed to constructor of creating single lateral
          # reaction
          #
          # @param [String] parent_var_name the name of variable of parent reaction
          # @return [Array] the arguments of lateral reaction constructor
          def creating_args(parent_var_name)
            [parent_var_name, sidepiece_var_name]
          end

          # Gets name of sidepiece species variable
          # @return [String] the name of variable which passed to constructor of
          #   creating lateral reaction
          def sidepiece_var_name
            namer.name_of(species)
          end
        end

      end
    end
  end
end
