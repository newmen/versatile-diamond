module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for units which uses when specie find algorithm builds
        module SpecieUnitBehavior

          # By default assigns internal anchor atoms to some names for using its in
          # find algorithm
          def first_assign!
            assign_anchor_atoms_name!
          end

          # Gets the code which checks that containing in unit instance is presented
          # or not
          #
          # @option [Boolean] :use_else_prefix flag which identifies that current
          #   instance has a several anchor atoms
          # @yield should return cpp code which will be used if unit instance is
          #   presented
          # @return [String] the cpp code string
          def check_existence(use_else_prefix: false, &block)
            define_anchor_atoms_line +
              code_condition(check_role_condition, use_else_prefix: use_else_prefix) do
                code_condition(check_specie_condition, &block)
              end
          end

          # Does nothing by default
          # @yield should return cpp code
          # @return [String] the cpp code string
          def check_species(&block)
            block.call
          end

        private

          # Assigns the name of anchor atoms variable
          def assign_anchor_atoms_name!
            namer.assign(Specie::ANCHOR_ATOM_NAME, atoms)
          end

          # By default doesn't define anchor atoms
          # @return [String] the empty string
          def define_anchor_atoms_line
            ''
          end

          # Gets a cpp code string that contain call a method for check existing
          # current specie in atom
          #
          # @return [String] the string with cpp condition
          def check_specie_condition
            method_name = original_specie.find_endpoint? ? 'hasRole' : 'checkAndFind'
            combine_condition(atoms, '||') do |var, atom|
              "!#{var}->#{method_name}(#{original_specie.enum_name}, #{role(atom)})"
            end
          end

          # Finds relation between passed atoms
          # @param [Array] pair_of_units_with_atoms the array of two items where each
          #   element is array where first item is target unit and second item is atom
          # @return [Concepts::Bond] the relation between atoms from each pair or nil
          #   if relation doesn't present
          def relation_between(*pair_of_units_with_atoms)
            atoms = pair_of_units_with_atoms.map(&:last)
            original_spec.relation_between(*atoms)
          end

          # Gets available relations for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the relations will be gotten
          # @return [Array] the list of relations
          def relations_of(atom)
            original_spec.links[atom]
          end

          # Checks that passed atom has any relations in context
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the relations will be checked
          # @return [Boolean] has relations or not
          def has_relations?(atom)
            rels = relations_of(atom)
            rels && !rels.empty?
          end

          # Gets the default engine framework class for parent specie
          # @return [String] the engine framework class for parent specie
          def specie_type
            'ParentSpec'
          end
        end

      end
    end
  end
end
