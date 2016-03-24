module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes species array variable
        class SpeciesArray < Core::Collection
          # @param [Statement] body
          # @return [For]
          def each(body)
            iterate(:s, body)
          end
        end

      end
    end
  end
end
