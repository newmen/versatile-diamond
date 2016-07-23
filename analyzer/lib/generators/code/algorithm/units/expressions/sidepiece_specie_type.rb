module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents lateral specie type statement
        class SidepieceSpecieType < Core::ObjectType
          class << self
            def []
              super('LateralSpec')
            end
          end
        end

      end
    end
  end
end
