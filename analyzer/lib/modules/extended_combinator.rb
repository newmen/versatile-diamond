module VersatileDiamond
  module Modules

    # Provides extended combinatoric methods
    module ExtendedCombinator
    private

      # Gets slices of all possible combinations of array items
      # @param [Array] array which items will be combinated
      # @param [Integer] min_num the minimal number of items in each element of first
      #   slice
      # @param [Integer] max_num the maximal number of items in each element of last
      #   slice
      # @return [Array] the list of all posible combinations
      # @example
      #   [1, 2, 3] => [
      #     [[]],
      #     [[1], [2], [3]],
      #     [[1, 2], [1, 3], [2, 3]],
      #     [[1, 2, 3]]
      #   ]
      # TODO: check standart library method for this
      def sliced_combinations(array, min_num, max_num = array.size)
        min_num.upto(max_num).map { |x| array.combination(x).to_a }
      end
    end

  end
end
