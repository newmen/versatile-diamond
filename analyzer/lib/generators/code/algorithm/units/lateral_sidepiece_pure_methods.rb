module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for reaction pure units
        module LateralSidepiecePureMethods
          include Algorithm::Units::ReactantCommonMethods
          include Algorithm::Units::SidepieceAbstractType

          # Anchor specie should has a name
          def define!
            kwargs = {
              name: Code::Specie::SIDE_SPECIE_NAME,
              next_name: false
            }
            kwargs[:type] = abstract_type unless species.one?
            dict.make_specie_s(species, **kwargs)
          end
        end

      end
    end
  end
end
