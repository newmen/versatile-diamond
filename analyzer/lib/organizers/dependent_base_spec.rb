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

      # Base spec could not be specific
      # @return [Boolean] false
      def specific?
        false
      end

      # Is excess spec or not
      # @return [Boolean] is excess spec or not
      def excess?
        parents.size == 1 && children.size == 1 && children.first.specific?
      end

      # По спеку построить граф.
      # Найти симметричные атомы и несемметричные
      # - Учесть количество атомов - чётный/нечётный
      # Реализовать операцию вычитания одного графа из другого.
      # - Проверяет, что если симметричные атомы различаются по типам в оставшемся куске, то запоминаем что родитель симметричный.





      # Для нахождения симметричных и несимметричных атомов использовать словарь пересечений. Для этого необходимо минимум два пересечения
      # {
      #   Atom => [Atom, Atom]
      # }



      # Organize dependencies from another specs by dynamic table
      # @param [BaseSpeciesTable] table the dynamic table of species dependencies
      def organize_dependencies!(table)
        cell = table.best(self)
        @rest = cell.residual unless self == cell.residual
        cell.specs.each do |spec|
          store_parent(spec)
          spec.store_child(self)
        end
      end

      def to_s
        "(#{name}, [#{parents.map(&:name).join(' ')}], " +
          "[#{children.map(&:to_s).join(' ')}])"
      end

      def inspect
        to_s
      end

    protected

      # Provides purge condition for initial minuend instance
      # @return [Proc] the condition for purging
      def purge_condition
        Proc.new { |_, links| links.empty? }
      end

      # Makes a new residual
      # @param [Array] links_arr the array that represent relations between atoms
      # @param [Set] residual_atoms the residual atoms after diff operation
      # @return [SpecResidual] the new residual
      def make_residual(links_arr, residual_atoms)
        SpecResidual.new(Hash[links_arr], residual_atoms)
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
