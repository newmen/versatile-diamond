module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from specie
        # @abstract
        class SingleSpecieUnit < MultiAtomsUnit
          include SymmetricCppExpressions

          # Also remember the unique parent specie
          # @param [Array] args passes to #super method
          # @param [UniqueSpecie] target_specie the major specie of current unit
          # @param [Array] atoms which uses for code generation
          def initialize(*args, target_specie, atoms)
            super(*args, atoms)
            @target_specie = target_specie
          end

          # Checks that passed spec equal to using specie
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec which will checked
          # @return [Boolean] is target spec or not
          def unit_spec?(spec)
            target_specie.proxy_spec.spec == spec
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
          def each_symmetry_lambda(closure_on_scope: false, &block)
            super(target_specie, closure_on_scope: closure_on_scope, &block)
          end

          # Gets the code line with definition of parent specie variable
          # @return [String] the definition of parent specie variable
          def define_target_specie_line
            define_specie_line(target_specie, avail_anchor)
          end

          # Gets code string with call getting atom from target specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be used for get an index from target specie
          # @return [String] code where atom getting from target specie
          # @override
          def atom_from_own_specie_call(atom)
            atom_from_specie_call(target_specie, atom)
          end
        end

      end
    end
  end
end
