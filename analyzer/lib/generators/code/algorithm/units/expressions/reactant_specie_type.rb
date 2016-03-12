module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents reactant type statement
        class ReactantSpecieType < Core::ObjectType
          class << self
            def []
              super('SpecificSpec')
            end
          end
        end

      end
    end
  end
end
