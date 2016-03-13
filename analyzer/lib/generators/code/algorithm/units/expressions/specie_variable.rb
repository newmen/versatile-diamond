module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents specie variable statement
        class SpecieVariable < Core::Variable
          # @param [Array] defined_vars
          # @param [SpecieVariable] iterable_var
          # @param [Core::Expression] body
          # @return [Core::OpCall]
          def iterate_symmetries(defined_vars, iterable_var, body)
            call('eachSymmetry', Core::Lambda[defined_vars, iterable_var, body])
          end

          # @param [Concepts::Atom | Concepts::SpecificAtom | Concepts::AtomReference]
          #   atom which value will be called from specie by index
          # @return [Core::OpCall]
          def atom_value(atom)
            call('atom', Core::Constant[instance.index(atom)])
          end
        end

      end
    end
  end
end
