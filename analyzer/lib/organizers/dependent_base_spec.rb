module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentSpec
      extend Forwardable

      def_delegators :@spec, :name, :size
      collector_methods :parent



      # Checks that other spec has same atoms and links between them
      # @param [DependentBaseSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        return false unless size == other.size
        intersec = Mcs::SpeciesComparator.contain?(
          spec, other.spec, separated_multi_bond: true)
      end


      # По спеку построить граф.
      # Реализовать операцию вычитания одного графа из другого.
      # - Производить новый зависимый.
      # - Проверяет, что если симметричные атомы различаются по типам в оставшемся куске, то запоминаем что родитель симметричный.
      # Производить замену атома и перестраивать граф.








      # Organize dependencies from another specs by containing check
      # @param [Array] possible_parents the array of possible parents in
      #   descending order
      def organize_dependencies!(possible_parents)


        # Строить таблицу соответствия.


        possible_parents.each do |possible_parent|
          if residue(links, possible_parent.links)
            store_parent(possible_parent)
            parent.store_child(self)
            break
          end
        end
      end

    private

      # Removes a spec from collection of children
      # @param [SpecificSpec] spec the removable child
      def remove_child(spec)
        childs.reject! { |s| s == spec }
      end

      # The large links contains small links?
      # @param [Hash] large_links the links from large spec
      # @param [Hash] small_links the links from small spec
      # @raise [RuntimeError] if some of multi-bond (in large or small links)
      #   is invalid
      # @return [Boolean] contains or not
      def residue(large_links, small_links)
        HanserRecursiveAlgorithm.contain?(large_links, small_links,
          separated_multi_bond: true)
      end
    end

  end
end
