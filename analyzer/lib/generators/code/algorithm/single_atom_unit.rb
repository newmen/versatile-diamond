module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for units which targeted to some atom
        class SingleAtomUnit < BaseUnit
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
            ap = Organizers::AtomProperties.new(original_spec, target_atom)
            "#{inspect_name_of(target_atom)}:#{ap.to_s}"
          end
        end

      end
    end
  end
end
