module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from one node
        # @abstract
        class MonoUnit < BaseCheckerUnit

          # Initializes the mono checking unit of code builder algorithm
          # @param [Array] default_args which will be passed to super class
          # @param [Instances::SpecieInstance] specie which will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          def initialize(*default_args, specie, atom)
            super(*default_args)
            @specie = specie
            @atom = atom
          end

          # Gets the current unit instance
          # @return [Array] the array with just one item
          def units
            [self]
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
            sn = "#{inspect_name_of(@specie)}:#{@specie.inspect}"
            "[#{sn}·#{inspect_name_of(@atom)}:#{@specie.properties_of(@atom)}]"
          end

        protected

          # Gets pair of current specie with atom
          # @return [Array] the current state
          def spec_atom
binding.pry # !!!!!!!!!!!!!!!!!!!!!
            [@specie.concept, @atom]
          end

          # Checks that symmetries of internal specie should be also checked
          # @return [Boolean] are symmetries should be checked or not
          def symmetric_unit?
            @specie.symmetric?(@atom)
          end
        end

      end
    end
  end
end
