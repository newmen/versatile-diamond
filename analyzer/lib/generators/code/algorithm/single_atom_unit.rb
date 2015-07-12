module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for units which targeted to some atom
        class SingleAtomUnit < SimpleUnit
          include SpecieUnitBehavior

          # Also store the target atom of unit
          # @param [Array] args of #super method
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   target_atom for current unit
          def initialize(*args, target_atom)
            super(*args, [target_atom])
          end

          def inspect
            "SAU:(#{inspect_target_atom})"
          end

        private

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_target_atom
            ap = atom_properties(original_spec, target_atom)
            "#{inspect_name_of(target_atom)}:#{ap}"
          end
        end

      end
    end
  end
end
