module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Garanties uniquality of all similar species
        class OtherSideSpecie < Tools::TransparentProxy

          delegate :atom?, :anchor?
          delegate :actual_role, :source_role
          delegate :var_name

          # @return [Boolean]
          def proxy?
            true
          end
        end

      end
    end
  end
end
