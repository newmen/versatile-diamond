module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions that calls advansed atom
        # methods of engine framework
        module AtomCppExpressions
        private

          # Makes code string with calling of engine method that names specByRole
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom which name will be used for method call
          # @param [UniqueSpecie] specie for which the code will be generated
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   getting_atom of which will be used for get a role of atom in specie
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(target_atom, specie, getting_atom)
            atom_var_name = namer.name_of(target_atom)
            role = specie.role(getting_atom)
            "#{atom_var_name}->specByRole<#{specie.class_name}>(#{role})"
          end
        end

      end
    end
  end
end
