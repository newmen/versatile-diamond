module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions that calls advansed atom
        # methods of engine framework
        module AtomCppExpressions
        protected

          # Gets the code line with definition of specie variable
          # @return [String] the definition of specie variable
          def define_specie_line(specie, atom)
            atom_call = spec_by_role_call(atom) # there calling overriden method
            namer.assign_next('specie', specie)
            define_var_line("#{specie.class_name} *", specie, atom_call)
          end

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

          # Gets atom properties
          # @param [Organizers::DependentWrappedSpec] dept_spec the context spec
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which properties will be gotten
          # @return [Organizers::AtomProperties] the properties of passed atom in
          #   passed context spec
          def atom_properties(dept_spec, atom)
            Organizers::AtomProperties.new(dept_spec, atom)
          end
        end

      end
    end
  end
end
