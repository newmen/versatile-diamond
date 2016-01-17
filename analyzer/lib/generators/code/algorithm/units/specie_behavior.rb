module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides logic for units which uses when specie find algorithm builds
        module SpecieBehavior

          # By default assigns internal anchor atoms to some names for using its in
          # find algorithm
          def first_assign!
            if !mono? && !whole?
              raise 'Incorrect starting point to specie find algorithm'
            elsif context.find_root?
              assign_anchor_atoms_name!
            else
              assign_anchor_specie_name!
            end
          end

          # Gets the code which checks that containing in unit instance is presented
          # or not
          #
          # @option [Array] epx passes to next block
          # @yield should return cpp code which will be used if unit instance is
          #   presented
          # @return [String] the cpp code string
          def check_existence(**epx, &block)
            define_anchor_atoms_code(**epx) do
              code_condition(check_specie_condition, &block)
            end
          end

          # Gets the code with checking internal species
          # @option [Array] epx passes to next block
          # @yield should return cpp code
          # @return [String] the cpp code string
          def check_species(**epx, &block)
            define_all_atoms_code(**epx, &block)
          end

        private

          # Gets the anchor atom which was defined before
          # @param [SpecieInstance] specie which which will be checked
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          # @override
          def avail_anchor_atom_of(specie)
            find_defined(select_anchors_of(specie, context.spec.anchors))
          end

          # Gets the code line or block with definition of atoms variable
          # @option [Array] epx passes to next block
          # @yield appends after definition line or into definition block
          # @return [String] the empty string
          def define_anchor_atoms_code(**epx, &block)
            if context.find_root?
              check_roles_condition(select_defined(uniq_atoms), **epx, &block)
            else
              check_species(**epx, &block)
            end
          end

          # Gets a cpp code string that contain call a method for check existing
          # current specie in atom
          #
          # @return [String] the string with cpp condition
          def check_specie_condition
            chain('||', uniq_atoms.map(&method(:check_specie_call)))
          end

          # Gets the code which checks that specie already defined in atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which role will be checked
          def check_specie_call(atom)
            method_name = context.find_endpoint? ? 'hasRole' : 'checkAndFind'
            full_method_name = "#{name_of(atom)}->#{method_name}"
            "#{full_method_name}(#{context.enum_name}, #{detect_role(atom)})"
          end

          # Gets the code with checking passed specie
          # @param [SpecieInstance] specie which which will be checked
          # @yield should return cpp code
          # @return [String] the cpp code string
          def check_specie_code(specie, &block)
            define_specie_code(avail_anchor_atom_of(specie), specie) do
              define_specie_atoms_code(specie, &block)
            end
          end

          # Finds relation between passed atoms
          # @param [Array] pair_of_units_with_atoms the array of two items where each
          #   element is pair where first item is unit and second item is atom
          # @return [Concepts::Bond] the relation between atoms from each pair or nil
          #   if relation isn't present
          def relation_between(*pair_of_units_with_atoms)
            atoms = pair_of_units_with_atoms.map(&:last)
            context.spec.relation_between(*atoms)
          end

          # Gets available relations for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the relations will be gotten
          # @return [Array] the list of relations
          def relations_of(atom)
            context.spec.links[atom]
          end

          # Checks that passed atom has any relations in context
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the relations will be checked
          # @return [Boolean] has relations or not
          def has_relations?(atom)
            rels = relations_of(atom)
            rels && !rels.empty?
          end
        end

      end
    end
  end
end
