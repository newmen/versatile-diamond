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
            block_given? ? index(&block) : (raise ArgumentError)

          delete_at(index || size)
        end
      end
    end

  end
end
