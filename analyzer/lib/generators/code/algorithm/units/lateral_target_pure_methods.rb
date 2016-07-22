module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for pure units of look around algorithm
        module LateralTargetPureMethods
          include Algorithm::Units::ReactantCommonMethods
          include Algorithm::Units::ReactantAbstractType

          # Anchor specie should has a name
          def define!
            dict.make_target_s(species)
          end
        end

      end
    end
  end
end
