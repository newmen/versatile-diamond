module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding reaction specific code from one node
        class MonoReactionUnit < MonoPureUnit
          include ReactionPureMethods

          # Anchor should has a name
          def define!
          end
        end

      end
    end
  end
end
