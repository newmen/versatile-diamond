module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Represents "this" instance
        class This < Constant
          class << self
            # @return [This]
            def []
              super('this')
            end
          end
        end

      end
    end
  end
end
