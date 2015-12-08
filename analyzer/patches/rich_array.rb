module VersatileDiamond
  module Patches

    module RichArray
      refine Array do
        # Removes one item from array
        # @param [Object] item some item from array
        # @yeild [Object] if passed instead of item then finds index of item
        # @return [Object] removed object
        def delete_one(item = nil, &block)
          index = item && !block_given? ?
            index(item) :
            (block_given? ? index(&block) : (raise ArgumentError))

          delete_at(index || size)
        end

        # Makes accurate diff between two collection so that deletes just one
        # correspond item from current collection
        # @param [Array] other the array of extracting items
        # @return [Array] the difference result
        def accurate_diff(other)
          arr2 = other.dup
          arr1 = dup
          arr1.delete_one(arr2.pop) until arr2.empty?
          arr1
        end

        # Groups the items by passed block
        # @yield [Object] for each item from which the grouping value will be gotten
        # @return [Array] the list of grouped arrays
        def groups(&block)
          (block_given? ? group_by(&block) : group_by { |x| x }).values
        end

        # Gets not unique items of array
        # @return [Array] the not unique items of original sequence
        def not_uniq
          select { |item| count(item) > 1 }.uniq
        end

        # Checks that array contains only equalent values
        # @param [Boolean] are all items equal between each other or not
        def all_equal?(&block)
          uniq(&block).size == 1
        end
      end
    end

  end
end
