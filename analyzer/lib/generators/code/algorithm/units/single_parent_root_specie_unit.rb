module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code of root specie that depends from one parent specie
        class SingleParentRootSpecieUnit < SingleSpecieUnit
          include SpecieUnitBehavior

          # Checks that specie is defined and check it symmetry overwise
          # @yield should return cpp code
          # @return [String] the cpp code string
          # @override
          def check_species(&block)
            if name_of(parent_specie) || any_defined?(atoms)
              block.call
            else
              define_target_specie_lambda do
                all_defined?(atoms) ? block.call : check_undefined_atom_roles(&block)
              end
            end
          end

          def inspect
            "SPRSU:(#{inspect_specie_atoms_names}])"
          end

        private

          alias :parent_specie :target_specie

          # Defines parent specie and checks it symmetry
          # @yield should return cpp code
          # @return [String] the cpp code string
          def define_target_specie_lambda(&block)
            define_target_specie_line + check_symmetries_if_need(closure: true, &block)
          end

          # Defines unnamed atoms and checks them roles
          # @yield should return cpp code for condition body
          # @return [String] the cpp code string with defining atoms and checking
          #   condition
          def check_undefined_atom_roles(&block)
            undefined_atoms = select_undefined(atoms)
            define_undefined_atoms_line +
              code_condition(check_atoms_roles_of(undefined_atoms), &block)
          end

          # Defines atoms variable line and reassing names to all internal atoms
          # @return [String] the string with definition of atoms variable
          def define_undefined_atoms_line
            values = atom_values # collect before erase
            namer.erase(atoms)
            namer.assign_next(Specie::INTER_ATOM_NAME, atoms)
            define_var_line('Atom *', atoms, values)
          end

          # Gets the twin atom for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the twin atom will be returned
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the correspond twin atom
          def twin(atom)
            twins = own_twins(atom)
            raise 'Incorrect number of twin atoms for current unit' if twins.size != 1
            twins.first
          end

          # Finds all twins of passed atom which where twin specie is own parent specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the twin atoms will be returned
          # @return [Array] the list of twin atoms
          def own_twins(atom)
            pwts = original_spec.parents_with_twins_for(atom)
            pwts.select { |pr, _| pr == parent_specie.proxy_spec }.map(&:last)
          end

          # Gets the anchor atom which was defined before
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          def avail_anchor
            find_defined(atoms) || avail_not_own_anchor
          end

          # Gets anchor atoms which was defined but not belongs to current unit
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available not own anchor atom
          def avail_not_own_anchor
            select_defined(original_spec.anchors).find do |atom|
              !own_twins(atom).empty?
            end
          end

          # Gets the code string with getting the parent specie from atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the parent specie will be gotten
          # @return [String] cpp code string with engine framework method call
          def spec_by_atom_call(atom)
            spec_by_role_call(atom, parent_specie, twin(atom))
          end

          # Gets code string with call getting atom from parent specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the twin of which will be used for get an index of it atom from
          #   parent specie
          # @return [String] code where atom getting from parent specie
          def atom_from_parent_call(specie, atom)
            atom_from_specie_call(specie, twin(atom))
          end

          # Gets code string with call getting atom from parent specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be used for get an index from parent specie
          # @return [String] code where atom getting from parent specie
          def atom_from_own_specie_call(atom)
            atom_from_parent_call(parent_specie, atom)
          end
        end

      end
    end
  end
end