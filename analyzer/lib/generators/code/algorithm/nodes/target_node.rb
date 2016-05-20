module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Represents node which is hold target reactant node and prevents lateral
        # reaction from target reactant node getting
        class TargetNode < LateralNode

          # @raise [Exception]
          def lateral_reaction
            raise 'Cannot get lateral reactoin from target reactant node'
          end
        end

      end
    end
  end
end
