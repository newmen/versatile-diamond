module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for units which targeted to some atom
        # @abstract
        class SingleAtomUnit < BaseUnit

          # Also store the target atom of unit
          # @param [Array] args of #super method
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom for current unit
          def initialize(*args, target_atom)
            super(*args)
            @target_atom = target_atom
          end

          def inspect
            atom_props = Organizers::AtomProperties.new(spec, target_atom)
            "SAU:(#{inspect_name_of(target_atom)}:#{atom_props.to_s})"
          end

        private

          attr_reader :target_atom

          # Gets the array with one item
          # @return [Array] the array with one target atom
          def atoms
            [target_atom]
          end
        end

      end
    end
  end
end
