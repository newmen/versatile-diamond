module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding reaction specific code from one node
        class MonoReactionUnit < MonoPureUnit
          include ReactionPureMethods
        end

      end
    end
  end
end
