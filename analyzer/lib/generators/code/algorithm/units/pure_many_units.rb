module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code from many nodes
        class PureManyUnits < BaseUnit

          # All different anchor atoms should have names
          # @param [VarsDictionary] context
          def entry_point!(context)
            if atoms.one?
              anchor = atoms.first
              var = one_atom_variable(anchor, name: Code::Specie::ANCHOR_ATOM_NAME)
              context.retain_var!(anchor, var)
            else
              raise 'Incorrect number of entry atoms'
            end
          end
        end

      end
    end
  end
end
