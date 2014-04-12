module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentSpec
      include MultiParentsSpec
      include MultiChildrenSpec
      include Minuend
      include ResidualContainerSpec

      def_delegators :@spec, :size, :external_bonds, :links

      def initialize(spec)
        super

        # TODO:
        # Найти симметричные атомы и несемметричные
        # - Учесть количество атомов - чётный/нечётный
        # - Проверяет, что если симметричные атомы различаются по типам в оставшемся куске, то запоминаем что родитель симметричный.

        # Для нахождения симметричных и несимметричных атомов использовать словарь пересечений. Для этого необходимо минимум два пересечения
        # {
        #   Atom => [Atom, Atom]
        # }

        # @symmetrical = []
        # @asymmetrical = []
      end

      # Base spec could not be specific
      # @return [Boolean] false
      def specific?
        false
      end

      # Is unused spec or not
      # @return [Boolean] is unused or not
      def unused?
        children.empty? && !reactant?
      end

      # Is excess spec or not
      # @return [Boolean] is excess spec or not
      def excess?
        parents.size == 1 && children.size == 1 && children.first.specific? &&
          !reactant?
      end

      # Excludes current spec. Instead of the current spec replaces the parent to the
      # child and vice versa. Should have only one parent and only one child.
      # @raise [RuntimeError] if spec is not excess and not unused
      def exclude
        raise 'Unexcess spec could be exclude or unused' unless excess? || unused?

        parent = parents.first
        child = children.first

        parent.remove_child(self) if parent
        child.remove_parent(self) if child

        child.store_parent(parent) if parent && child
        child.store_rest(rest) if child
      end

      # Organize dependencies from another specs by dynamic table
      # @param [BaseSpeciesTable] table the dynamic table of species dependencies
      def organize_dependencies!(table)
        cell = table.best(self)
        store_rest(cell.residual) unless self == cell.residual
        cell.specs.each { |spec| store_parent(spec) }
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

      # Is current spec reactant or not
      # @return [Boolean] is reactant or not
      def reactant?
        !(reactions.empty? && theres.empty?)
      end
    end

  end
end
