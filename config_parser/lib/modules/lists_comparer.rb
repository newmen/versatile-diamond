module VersatileDiamond

  module ListsComparer
    def lists_are_identical?(list1, list2, &block)
      return false if list1.size != list2.size

      list1, list2 = list1.to_a.dup, list2.to_a.dup
      list1.reduce(true) do |acc, item1|
        i = list2.index { |item2| block[item1, item2] }
        acc && i && list2.delete_at(i)
      end
    end
  end

end
