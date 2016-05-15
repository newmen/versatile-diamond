module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides methods for pure units of look around algorithm
        module LateralTargetPureMethods
          include Algorithm::Units::ReactantCommonMethods

          # Anchor specie should has a name
          def define!
            dict.make_target_s(species)
          end

          # @return [Boolean]
          def checkable?
            false
          end
        end

      end
    end
  end
end
