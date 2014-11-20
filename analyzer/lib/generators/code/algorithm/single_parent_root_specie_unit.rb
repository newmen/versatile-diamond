module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code of root specie that depends from one parent specie
        class SingleParentRootSpecieUnit < SingleSpecieUnit
          include SpecieUnitBehavior
          include SmartAtomCppExpressions

          def inspect
            "RSU:(#{inspect_specie_atoms_names}])"
          end

        private

          alias :parent_specie :target_specie

          # Gets the twin atom for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the twin atom will be returned
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the correspond twin atom
          def twin(atom)
            twins = original_spec.twins_of(atom)
            raise 'Incorrect number of twin atoms for current unit' if twins.size != 1
            twins.first
          end

          # Gets the code line with definition of parent specie variable
          # @return [String] the definition of parent specie variable
          def define_target_specie_line
            avail_atom = atoms.find { |a| namer.name_of(a) }
            atom_call = spec_by_role_call(avail_atom)

            namer.assign_next('parent', parent_specie)
            define_var_line("#{specie_type} *", parent_specie, atom_call)
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
          def atom_from_specie_call(atom)
            super(parent_specie, twin(atom))
          end

          # Gets the engine framework class for parent specie
          # @return [String] the engine framework class for parent specie
          def specie_type
            'ParentSpec'
          end

          # Prepare the the passed atom to correspond twin of target parent specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the linked atom will be checked
          # @param [Concepts::Bond] position by which the linked atom will be checked
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom which linked with passed atom by passed position or nil
          # @override
          def position_with(atom, position)
            super(twin(atom), position)
          end
        end

      end
    end
  end
end
