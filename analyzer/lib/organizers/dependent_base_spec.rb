module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentSpec
      extend Forwardable
      include Minuend

      def_delegators :@spec, :name, :size, :external_bonds, :links
      collector_methods :parent
      attr_reader :rest

      def initialize(spec)
        super

        # @symmetrical = []
        # @asymmetrical = []
        # @graph = Mcs::Graph.new(spec.links)

      end

      # По спеку построить граф.
      # Найти симметричные атомы и несемметричные
      # - Учесть количество атомов - чётный/нечётный
      # Реализовать операцию вычитания одного графа из другого.
      # - Производить остаток.
      # - Подменять остающийся атом ссылкой на соответствующий атом меньшей структуры
      # - Проверяет, что если симметричные атомы различаются по типам в оставшемся куске, то запоминаем что родитель симметричный.
      # Производить замену атома и перестраивать граф.





      # Для нахождения симметричных и несимметричных атомов использовать словарь пересечений. Для этого необходимо минимум два пересечения
      # {
      #   Atom => [Atom, Atom]
      # }



      # Organize dependencies from another specs by dynamic table
      # @param [BaseSpeciesTable] table the dynamic table of species dependencies
      def organize_dependencies!(table)
        cell = table.best(self)
        @rest = cell.residual
        cell.specs.each { |spec| store_parent(spec) }
      end

    private

      # # Removes a spec from collection of children
      # # @param [SpecificSpec] spec the removable child
      # def remove_child(spec)
      #   childs.reject! { |s| s == spec }
      # end
    end

  end
end
