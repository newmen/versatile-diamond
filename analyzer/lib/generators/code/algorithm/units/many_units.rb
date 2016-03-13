module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from many nodes
        class ManyUnits < BaseUnit

          # All different anchor atoms should have names
          def entry_point!
            if atoms.one?
              anchor = atoms.first
              dict.make_atom_s(anchor, name: Code::Specie::ANCHOR_ATOM_NAME)
            else
              raise 'Incorrect number of entry atoms'
            end
          end
        end

      end
    end
  end
end
