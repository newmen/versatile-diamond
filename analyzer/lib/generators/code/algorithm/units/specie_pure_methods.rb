module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for specie pure units
        module SpeciePureMethods
          def define_atom_anchor!
            kwargs = { name: Code::Specie::ANCHOR_ATOM_NAME, next_name: false }
            dict.make_atom_s(atoms.first, **kwargs)
          end

          def define_specie_anchor!
            kwargs = { name: Code::Specie::ANCHOR_SPECIE_NAME, next_name: false }
            dict.make_specie_s(species.first, **kwargs)
          end
        end

      end
    end
  end
end
