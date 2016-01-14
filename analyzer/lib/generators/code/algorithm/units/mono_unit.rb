module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from one node
        # @abstract
        class MonoUnit < BaseCheckerUnit

          # Initializes the mono checking unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Object] relations_checker which provides global links
          # @param [SpecieInstance] specie which uses in current building algorithm
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          def initialize(generator, namer, relations_checker, specie, atom)
            super(generator, namer)
            @relations_checker = relations_checker
            @specie = specie
            @atom = atom
          end

          # Gets the current checking species instance
          # @return [Array] the array with just one item
          def species
            [@specie]
          end

          # Gets the list of checking atoms
          # @return [Array] the array with just one item
          def atoms
            [@atom]
          end

          # Gets the list of checking states
          # @return [Array] the array with just one intem
          def specs_atoms
            [spec_atom]
          end

          # Gets the list of all using relations
          # @return [Array] the array with just one intem
          def all_using_relations
            [using_relations]
          end

          # Gets self unit as item of set if passed atom equal to internal atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be compared with internal atom
          # @return [Array] the units which uses passed atom
          def inner_units_with(atom)
            @atom == atom ? [self] : []
          end

          # Detects the role of passed atom
          # @return [Integer] the role of atom
          def detect_role(atom)
            @specie.role(atom)
          end

          def inspect
            sn = "#{inspect_name_of(@specie)}:#{@specie.original.inspect}"
            "[#{sn}·#{inspect_name_of(@atom)}:#{@specie.properties_of(@atom)}]"
          end

        protected

          # Gets pair of current specie with atom
          # @return [Array] the current state
          def spec_atom
            [@specie.spec, @atom]
          end

        private

          attr_reader :relations_checker

          # Checks that state of passed unit is same as current state
          # @param [MonoUnit] other comparing unit
          # @return [Boolean] are equal states of units or not
          def same_inner_state?(other)
            same_sa?(spec_atom, other.spec_atom)
          end

          # Checks that symmetries of internal specie should be also checked
          # @return [Boolean] are symmetries should be checked or not
          def symmetric_context?
            symmetric_atom_of?(@specie, @atom)
          end
        end

      end
    end
  end
end
