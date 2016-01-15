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
          # @option [Boolean] :use_else_prefix flag which identifies that current
          #   instance has a several anchor atoms
          # @yield should return cpp code which will be used if unit instance is
          #   presented
          # @return [String] the cpp code string
          def check_existence(use_else_prefix: false, &block)
            define_anchor_atoms_line do
              code_condition(check_roles_condition, use_else_prefix: use_else_prefix) do
                code_condition(check_specie_condition, &block)
              end
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
            namer.assign(Specie::ANCHOR_ATOM_NAME, uniq_atoms)
          end

          # Assigns the name of anchor specie variable
          def assign_anchor_specie_name!
            namer.assign(Specie::ANCHOR_SPECIE_NAME, uniq_species)
          end

          # Gets the code line or block with definition of atoms variable
          # @yield appends after definition line or into definition block
          # @return [String] the empty string
          def define_anchor_atoms_code(&block)
            assign_anchor_atoms_name! unless any_defined?(uniq_atoms)
            if context.find_root?
              define_var_line('Atom *', uniq_atoms, values) + block.call
            elsif whole?
              combine_anchor_atoms_block(uniq_species.first, &block)
            else
              raise 'Incorrect unit to define the anchor atoms'
            end
          end

          # Combines the composed block with definition and checking of anchor atoms
          # @param [SpecieInstance] specie which atoms will be defined
          # @yield deepest nests into definition block
          # @return [String] the definition of anchor atoms variable block
          def combine_anchor_atoms_block(specie, &block)
            inlay_procs(block) do |nest|
              nest[:each_symmetry_lambda, specie] if symmetric_unit?
              unless symmetric_atoms.empty?
                nest[:same_atoms_condition, specie, *symmetric_atoms]
              end
            end
          end

          # Gets a cpp code string that contain call a method for check existing
          # current specie in atom
          #
          # @return [String] the string with cpp condition
          def check_specie_condition
            chain('||', *uniq_atoms.map(&method(:check_specie_call)))
          end

          # Gets the code which checks that specie already defined in atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which role will be checked
          def check_specie_call(atom)
            method_name = context.find_endpoint? ? 'hasRole' : 'checkAndFind'
            full_method_name = "#{name_of(atom)}->#{method_name}"
            "#{full_method_name}(#{context.enum_name}, #{detect_role(atom)})"
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
