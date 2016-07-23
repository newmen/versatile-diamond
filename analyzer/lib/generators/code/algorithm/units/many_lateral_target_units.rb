module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding look around targets specific code from many nodes
        class ManyLateralTargetUnits < ManyPureUnits
          include LateralTargetPureMethods
        end

      end
    end
  end
end
