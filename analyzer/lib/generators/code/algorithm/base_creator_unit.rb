module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for creator units
        # @abstract
        class BaseCreatorUnit
          include CommonCppExpressions
          include SmartAtomCppExpressions

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Object] original_target which uses in current building algorithm
          # @param [Array] defined_species all previously defined unique species
          def initialize(namer, original_target, defined_species)
            @namer = namer
            @original_target = original_target
            @defined_species = defined_species.sort
          end

        private

          attr_reader :namer, :original_target, :defined_species

          # Gets a code string with defined variable
          # @param [String] type of defining variable
          # @param [String] single_name which will be passed to namer for assign name
          #   to array of passed atoms
          # @param [Array] atoms which will be defined
          # @return [String] the string with defined atoms variable
          def redefine_vars_line(type, single_name, vars)
            names = vars.map { |a| namer.name_of(a) }
            namer.reassign(single_name, vars)
            define_var_line("#{type} *", vars, names)
          end
        end

      end
    end
  end
end
