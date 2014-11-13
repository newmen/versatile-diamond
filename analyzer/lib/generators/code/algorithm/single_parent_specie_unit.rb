module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from parent specie
        class SingleParentSpecieUnit < SingleSpecieUnit
          include SpecieUnitBehavior

          # Assigns the name for internal parent specie, that it could be used when the
          # algorithm generating
          # @override
          def first_assign!
            namer.assign(Specie::ANCHOR_SPECIE_NAME, parent_specie)
          end

          # Also checks that internal parent specie is symmetric and if it is truth
          # then wraps the calling of super method to each symmetry lambda method of
          # engine framework
          #
          # @return [String] the string with cpp code which check existence of current
          #   unit, when simulation do
          # @override
          def check_existence(*)
            if symmetric?
              each_symmetry_lambda { super }
            else
              super
            end
          end

          def inspect
            "SPSU:(#{inspect_specie_atoms_names}])"
          end

        private

          alias :parent_specie :target_specie

          # Checks that internal parent specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            atoms.any? { |a| parent_specie.symmetric_atom?(twin(a)) }
          end

          # Gets the twin atom for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the twin atom will be returned
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the correspond twin atom
          def twin(atom)
            twins = spec.twins_of(atom)
            raise 'Incorrect number of twin atoms for current unit' if twins.size != 1
            twins.first
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

          # Gets the code line with definition of anchor atom variables
          # @return [String] the definition anchor atom variables code
          # @override
          def define_anchor_atoms_lines
            assign_anchor_atoms_name!
            values = atoms.map(&method(:atom_from_specie_call))
            define_var_line('Atom *', atoms, values)
          end

          # Gets the code line with definition of parent specie variable
          # @return [String] the definition of parent specie variable
          def define_target_specie_line
            avail_atom = atoms.find { |a| namer.name_of(a) }
            atom_call = spec_by_role_call(avail_atom)
            namer.assign_next('parent', parent_specie)
            define_var_line("#{specie_type} *", parent_specie, atom_call)
          end

          # Gets the engine framework class for parent specie
          # @return [String] the engine framework class for parent specie
          def specie_type
            'ParentSpec'
          end

          # Gets the code string with getting the parent specie from atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the parent specie will be gotten
          # @return [String] cpp code string with engine framework method call
          # @override
          def spec_by_role_call(atom)
            super(atom, parent_specie, twin(atom))
          end
        end

      end
    end
  end
end
