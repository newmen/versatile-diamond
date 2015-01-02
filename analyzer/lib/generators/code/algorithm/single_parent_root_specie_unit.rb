module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code of root specie that depends from one parent specie
        class SingleParentRootSpecieUnit < SingleSpecieUnit
          include SpecieUnitBehavior

          # Checks that specie is defined and check it symmetry overwise
          # @yield should return cpp code
          # @return [String] the cpp code string
          # @override
          def check_species(&block)
            if namer.name_of(parent_specie) || atoms.any? { |a| namer.name_of(a) }
              block.call
            else
              define_target_specie_lambda do
                if atoms.all? { |a| namer.name_of(a) }
                  block.call
                else
                  check_undefined_atom_roles(&block)
                end
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
            define_target_specie_line +
              if symmetric?
                each_symmetry_lambda(closure_on_scope: true, &block)
              else
                block.call
              end
          end

          # Defines unnamed atoms and checks them roles
          # @yield should return cpp code for condition body
          # @return [String] the cpp code string with defining atoms and checking
          #   condition
          def check_undefined_atom_roles(&block)
            undefined_atoms = atoms.reject { |a| namer.name_of(a) }
            define_undefined_atoms_line +
              code_condition(check_atoms_roles_of(undefined_atoms), &block)
          end

          # Checks that internal parent specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            atoms.any? { |a| parent_specie.symmetric_atom?(twin(a)) }
          end

          # Defines atoms variable line and reassing names to all internal atoms
          # @return [String] the string with definition of atoms variable
          def define_undefined_atoms_line
            values = atoms.map do |a|
              namer.name_of(a) || atom_from_own_specie_call(a)
            end

            namer.erase(atoms)
            namer.assign_next('atom', atoms)
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
            pwts = original_spec.parents_with_twins_for(atom).select do |pr, _|
              pr == parent_specie.proxy_spec
            end
            pwts.map(&:last)
          end

          # Gets the anchor atom which was defined before
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          def avail_anchor
            atoms.find { |a| namer.name_of(a) } || avail_not_own_anchor
          end

          # Gets anchor atoms which was defined but not belongs to current unit
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available not own anchor atom
          def avail_not_own_anchor
            original_spec.anchors.select { |a| namer.name_of(a) }.find do |atom|
              !own_twins(atom).empty?
            end
          end

          # Gets the code string with getting the parent specie from atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the parent specie will be gotten
          # @return [String] cpp code string with engine framework method call
          # @override
          def spec_by_role_call(atom)
            super(atom, parent_specie, twin(atom))
          end

          # Gets code string with call getting atom from parent specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the twin of which will be used for get an index of it atom from
          #   parent specie
          # @return [String] code where atom getting from parent specie
          # @override
          def atom_from_specie_call(specie, atom)
            super(specie, twin(atom))
          end
        end

      end
    end
  end
end
