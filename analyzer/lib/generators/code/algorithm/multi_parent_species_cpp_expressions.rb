module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains methods for generate cpp expressions with using parent species
        module MultiParentSpeciesCppExpressions
        private

          # Gets parent specie and correspond twin for passed atom
          # @yield [UniqueSpecie, Atom] does for select parent and twin
          # @return [Array] the array of two items
          def parent_with_twin_for(atom, &block)
            specs_to_parents = Hash[parent_species.map { |pr| [pr.proxy_spec, pr] }]
            pwts = spec.parents_with_twins_for(atom).map do |proxy_parent, twin|
              [specs_to_parents[proxy_parent], twin]
            end
            pwts.find(&block)
          end

          # Makes code string with calling of engine method that names specByRole
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which name will be used for method call
          # @param [UniqueSpecie] parent for which the code will be generated
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin of which will be used for get a role of atom in parent specie
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(atom, parent, twin)
            atom_var_name = namer.name_of(atom)
            parent_class_name = parent.class_name
            twin_role = parent.role(twin)
            "#{atom_var_name}->specByRole<#{parent_class_name}>(#{twin_role})"
          end
        end

      end
    end
  end
end
