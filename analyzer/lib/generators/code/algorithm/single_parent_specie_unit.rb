module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from parent specie
        class SingleParentSpecieUnit < MultiAtomsUnit
          include SymmetricCppExpressions
          include ParentSpecieCppExpressions

          # Also remember the unique parent specie
          # @param [Array] args passes to #super method
          # @param [UniqueSpecie] parent_specie the major specie of current unit
          def initialize(*args, parent_specie, atoms)
            super(*args, atoms)
            @parent_specie = parent_specie
          end

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
            pn = "#{inspect_name_of(parent_specie)}:#{parent_specie.original.inspect}"
            "SPSU:(#{pn}·[#{inspect_atoms_names.join('|')}])"
          end

        private

          attr_reader :parent_specie

          # Gets the using name of parent specie variable
          # @return [String] the name of internal parent specie variable
          def parent_specie_var_name
            namer.name_of(parent_specie)
          end

          # Checks that internal parent specie is symmetric by target atom
          # @return [Boolean] is symmetric or not
          def symmetric?
            parent_specie.symmetric_atom?(twin(target_atom))
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
          def atom_from_parent_call(atom)
            super(parent_specie, twin(atom))
          end

          # Gets the code line with definition of anchor atom variables
          # @return [String] the definition anchor atom variables code
          # @override
          def define_anchor_atoms
            assign_anchor_atoms!
            values = atoms.map(&method(:atom_from_parent_call))
            define_var_line('Atom *', atoms, values)
          end

          # Specifies arguments of super method
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          # @override
          def each_symmetry_lambda(&block)
            super(parent_specie, 'ParentSpec', clojure_on_scope: false, &block)
          end
        end

      end
    end
  end
end
