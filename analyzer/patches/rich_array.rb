module VersatileDiamond
  module Patches

    module RichArray
      refine Array do
        # Maps the current array to new array which items are non empty arrays
        # @yield [Object] get each new item from item of original array
        # @return [Array] the array of non empty arrays
        def map_non_empty(&block)
          each_with_object([]) do |item, acc|
            sub_array = block[item]
            acc << sub_array unless sub_array.empty?
          end
        end

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
          (block_given? ? group_by(&block) : group_by(&:itself)).values
        end

        # @param [Array] other
        # @return [Array] pairs
        def smart_zip(other)
          oz = other.size
          if size == oz
            zip(other)
          elsif size < oz && one?
            other.zip(cycle).map(&:rotate)
          elsif size > oz && other.one?
            zip(other.cycle)
          else
            raise ArgumentError, 'Incorrect number of items'
          end
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
