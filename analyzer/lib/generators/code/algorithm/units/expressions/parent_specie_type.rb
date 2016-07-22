module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents parent specie type statement
        class ParentSpecieType < Core::ObjectType
          class << self
            def []
              super('ParentSpec')
            end
          end
        end

      end
    end
  end
end
