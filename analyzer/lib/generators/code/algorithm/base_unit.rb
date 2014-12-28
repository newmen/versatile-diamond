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

          # Gets a cpp code string that contain call a method for check atom role
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_role_condition
            combine_condition(role_atoms, '&&') do |var, atom|
              "#{var}->is(#{role(atom)})"
            end
          end

        private

          attr_reader :generator, :namer

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            namer.name_of(obj) || 'undef'
          end

          # Gets the index of passed atom from generator's classifer by original spec
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be classified
          # @return [Integer] the role of passed atom
          def role(atom)
            generator.classifier.index(dept_spec_for(atom), atom)
          end
        end

      end
    end
  end
end
