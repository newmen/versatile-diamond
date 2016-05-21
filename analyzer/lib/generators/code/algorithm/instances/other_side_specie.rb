module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Garanties uniquality of all similar species
        class OtherSideSpecie < Tools::TransparentProxy
          comparable

          # @return [Boolean]
          def proxy?
            true
          end
        end

      end
    end
  end
end
