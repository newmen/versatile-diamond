module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding specie specific code from one node
        class MonoSpecieUnit < MonoPureUnit
          include SpeciePureMethods

          # Anchor should has a name
          def define!
            parent = species.first
            if parent.none? || parent.actual.spec.complex?
              define_atom_anchor!
            else
              define_specie_anchor!
            end
          end
        end

      end
    end
  end
end
