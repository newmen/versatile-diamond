module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates lateral reaction selector algorithm
        class LateralSelectorScopeUnit
          # @param [Expressions::VarsDictionary] dict
          # @param [Integer] min_quantity
          def initialize(dict, min_quantity)
            @dict = dict
            @min_quantity = min_quantity
          end

          def define!
            @dict.make_iterator(:num)
            @dict.make_chunks_list
            @dict.make_chunks_first_item if @min_quantity == 1
          end
        end

      end
    end
  end
end
