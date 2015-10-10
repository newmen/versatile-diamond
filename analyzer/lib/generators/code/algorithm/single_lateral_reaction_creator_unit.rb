module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Makes lines of code which describes creation of single lateral reaction
        # @abstract
        class SingleLateralReactionCreatorUnit < BaseReactionCreatorUnit

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [LateralReaction] reaction which will created by current algorithm
          # @param [Array] species the list of all previously defined unique species
          def initialize(namer, reaction, species)
            super(namer, species)
            @reaction = reaction
          end

        private

          # Gets the string with memory allocation of lateral reaction
          # @param [String] parent_var_name the name of variable of parent reaction
          # @return [String] the cpp code string
          def alloc_str(parent_var_name)
            args_str = creating_args(parent_var_name).join(', ')
            "new #{creating_class}(#{args_str})"
          end

          # Gets the reaction which will be crated
          # This method is required by deived classes
          #
          # @return [LateralReaction] reaction which will created by current algorithm
          def creating_reaction
            @reaction
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
            namer.name_of(sidepiece_species)
          end
        end

      end
    end
  end
end
