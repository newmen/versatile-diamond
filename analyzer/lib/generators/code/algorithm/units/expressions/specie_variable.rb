module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents specie variable statement
        class SpecieVariable < Core::Variable
          # @param [Array] defined_vars
          # @param [SpecieVariable] iterable_var
          # @param [Core::Expression] body
          # @return [Core::FunctionCall]
          def iterate_symmetries(defined_vars, iterable_var, body)
            call('eachSymmetry', Core::Lambda[defined_vars, iterable_var, body])
          end
        end

      end
    end
  end
end
