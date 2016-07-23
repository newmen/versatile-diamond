module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Decorates lateral reaction selector algorithm
        class LateralSelectorScopeUnit
          # @param [Expressions::VarsDictionary] dict
          def initialize(dict)
            @dict = dict
          end

          def define!
            @dict.make_iterator(:num)
            @dict.make_chunks_list
            @dict.make_chunks_first_item
          end
        end

      end
    end
  end
end
