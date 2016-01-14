module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides logic for units which uses when reaction find algorithm builds
        module ReactantBehavior
          include Algorithm::Units::ReactantUnitCommonBehavior
          include Algorithm::Units::SpecificSpecDefiner
        end

      end
    end
  end
end
