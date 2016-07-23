module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding specie specific code from many nodes
        class ManySpecieUnits < ManyPureUnits
          include SpeciePureMethods

          # Anchor should has a name
          def define!
            if species.one?
              define_specie_anchor!
            elsif atoms.one?
              define_atom_anchor!
            else
              raise 'Incorrect number of entry atoms'
            end
          end
        end

      end
    end
  end
end
