module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes atoms array variable
        class AtomsArray < Core::Collection
          # @param [Statement] body
          # @return [For]
          def each(body)
            iterate(:a, body)
          end
        end

      end
    end
  end
end
