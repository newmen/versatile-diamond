module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Garanties uniquality of all similar species
        class OtherSideSpecie < Tools::TransparentProxy
          # Compares two other side species
          # @param [OtherSideSpecie] other comparing proxy specie
          # @return [Integer] the result of original species comparing
          def <=> (other)
            original <=> other.original
          end
        end

      end
    end
  end
end
