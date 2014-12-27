module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for algorithm builder units
        # @abstract
        class BaseUnit
          include SpeciesUser
          include CommonCppExpressions
          include NeighboursCppExpressions
          include SpecieCppExpressions

          # Initializes the empty unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Array] atoms the array of target atoms
          def initialize(generator, namer, atoms)
            @generator = generator
            @namer = namer
            @atoms = atoms
          end

        protected

          attr_reader :atoms

          # Atomic specie is always single
          # @return [Boolean] true
          def single?
            atoms.size == 1
          end

          # Are all atoms has lattice
          # @return [Boolean] are all atoms or not
          def latticed?
            atoms.all?(&:lattice)
          end

          # Gets the list of atoms which belongs to anchors of target concept
          # @return [Array] the list of atoms that belonga to anchors
          def role_atoms
            atoms
          end

        private

          attr_reader :generator, :namer

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            namer.name_of(obj) || 'undef'
          end
        end

      end
    end
  end
end
