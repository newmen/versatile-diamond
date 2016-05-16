module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Garanties uniquality of all similar species
        class OtherSideSpecie < Tools::TransparentProxy
          binary_operations :'<=>'

          # @return [Boolean]
          def proxy?
            true
          end
        end

      end
    end
  end
end
