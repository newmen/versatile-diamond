module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentSpec
      include MultiParentsSpec
      include MultiChildrenSpec
      include Minuend
      include ResidualContainerSpec

      def_delegators :@spec, :size, :external_bonds, :links, :gas?

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

      # Checks that other spec has same atoms and links between them
      # @param [DependentBaseSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        other.is_a?(DependentSpec) ? spec.same?(other.spec) : other.same?(self)
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

        if parent
          parent.remove_child(self)
          child.replace_parent(parent) if child
        elsif child
          child.remove_parent(self)
        end
      end

      # Makes spec from self where each atom reference replaced by simple atom
      # @return [DependentBaseSpec] the closed base specie
      def closed
        self.class.new(spec.closed)
      end

      # Organize dependencies from another specs by dynamic table
      # @param [BaseSpeciesTable] table the dynamic table of species dependencies
      def organize_dependencies!(table)
        cell = table.best(self)
        if cell # if not only one specie in table
          store_rest(cell.residual) unless self == cell.residual
          cell.specs.each { |spec| store_parent(spec) }
        end
      end

      def to_s
        "(#{name}, [#{parents.map(&:name).join(' ')}], " +
          "[#{children.map(&:to_s).join(' ')}])"
      end

      def inspect
        to_s
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
