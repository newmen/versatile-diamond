module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from specie
        # @abstract
        class SingleSpecieUnit < MultiAtomsUnit
          include SymmetricCppExpressions
          include SpecieCppExpressions

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
          def each_symmetry_lambda(&block)
            super(target_specie, specie_type, clojure_on_scope: false, &block)
          end
        end

      end
    end
  end
end
