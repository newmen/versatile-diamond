module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from specie
        # @abstract
        class SingleSpecieUnit < MultiAtomsUnit
          include SmartAtomCppExpressions
          include SymmetricCppExpressions

          # Also remember the unique parent specie
          # @param [Array] args passes to #super method
          # @param [UniqueSpecie] target_specie the major specie of current unit
          # @param [Array] atoms which uses for code generation
          def initialize(*args, target_specie, atoms)
            super(*args, atoms)
            @target_specie = target_specie
          end

        private

          attr_reader :target_specie

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_specie_atoms_names
            tsn = "#{inspect_name_of(target_specie)}:#{target_specie.original.inspect}"
            "#{tsn}·[#{inspect_atoms_names}]"
          end

          # Specifies arguments of super method
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          # @override
          def each_symmetry_lambda(clojure_on_scope: false, &block)
            super(
              target_specie, specie_type, clojure_on_scope: clojure_on_scope, &block)
          end

          # Gets the code line with definition of parent specie variable
          # @return [String] the definition of parent specie variable
          def define_target_specie_line
            atom_call = spec_by_role_call(avail_anchor)
            namer.assign_next('specie', target_specie)
            define_var_line("#{target_specie.class_name} *", target_specie, atom_call)
          end

          # Checks the atom linked with passed atom by passed position
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the linked atom will be checked
          # @param [Concepts::Bond] position by which the linked atom will be checked
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom which linked with passed atom by passed position or nil
          def position_with(atom, position)
            dept_spec = target_specie.spec
            awr = dept_spec.relations_of(atom, with_atoms: true).find do |_, r|
              r == position
            end
            awr && awr.first
          end

          # Gets the cpp code string with comparison the passed atoms
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   linked_atom the atom from target specie which will be compared
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   next_atom the atom from another specie which will be compared
          # @return [String] the cpp code string with comparison the passed atoms
          #   between each other
          def not_own_atom_condition(linked_atom, next_atom)
            specie_call = atom_from_specie_call(linked_atom)
            next_atom_var_name = namer.name_of(next_atom)
            "#{next_atom_var_name} != #{specie_call}"
          end
        end

      end
    end
  end
end
