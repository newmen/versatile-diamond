module VersatileDiamond
  module Modules

    # Provides methods for lists comparing
    module ListsComparer
      # Compares all lists by passed block
      # @param [Array] list_of_lists
      # @yield [Object, Object] compares two elements from each list
      # @return [Boolean] lists are identical or not
      def lists_are_identical?(*list_of_lists, &block)
        block = :==.to_proc unless block_given?
        list_of_lists.each_cons(2).all? { |lists| similar_items?(*lists, &block) }
      end

      # Compares two lists by passed block
      # @param [Array] list1 the first comparing list
      # @param [Array] list2 the second comparing list
      # @yield [Object, Object] compares two elements from each list
      # @return [Boolean] lists are identical or not
      def similar_items?(list1, list2, &block)
        return true if list1.equal?(list2)
        return false if list1.size != list2.size

        list1, list2 = list1.to_a.dup, list2.to_a.dup
        !!list1.reduce(true) do |acc, item1|
          acc && (i = list2.index { |item2| block[item1, item2] }) &&
            (list2.delete_at(i) || item1.nil?)
        end
      end
    end

  end
end
