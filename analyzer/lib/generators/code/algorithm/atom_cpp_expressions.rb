module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions that calls advansed atom
        # methods of engine framework
        module AtomCppExpressions
          extend Forwardable

        protected

          # Gets the code line with definition of specie variable
          # @return [String] the definition of specie variable
          def define_specie_line(specie, atom)
            atom_call = spec_by_role_call(atom) # there calling overriden method
            namer.assign_next(Specie::INTER_SPECIE_NAME, specie)
            define_var_line("#{specie.class_name} *", specie, atom_call)
          end

        private

          def_delegator :generator, :atom_properties

          # Makes code string with calling of engine method that names specByRole
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom which name will be used for method call
          # @param [UniqueSpecie] specie for which the code will be generated
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   getting_atom of which will be used for get a role of atom in specie
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(target_atom, specie, getting_atom)
            unless specie.proxy_spec.anchors.include?(getting_atom)
              ap = atom_properties(specie.proxy_spec, getting_atom)
              fail "Atom (#{ap}) is not an anchor for using specie (#{specie.spec})"
            end

            role = specie.role(getting_atom)
            "#{name_of(target_atom)}->specByRole<#{specie.class_name}>(#{role})"
          end
        end

      end
    end
  end
end
