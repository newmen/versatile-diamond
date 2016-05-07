module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding reaction specific code from many nodes
        class ManyReactionUnits < ManyPureUnits
          include ReactionPureMethods

          # Anchor should has a name
          def define!
          end
        end

      end
    end
  end
end
