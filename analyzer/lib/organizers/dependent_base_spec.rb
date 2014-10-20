module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentWrappedSpec

      # Checks that other spec has same atoms and links between them
      # @param [DependentBaseSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        other.is_a?(DependentSpec) ? spec.same?(other.spec) : other.same?(self)
      end

      # Checks that spec is unused
      # @return [Boolean] is unused or not
      def unused?
        children.empty? && !reactant?
      end

      # Checks that spec is excess
      # @return [Boolean] is excess spec or not
      def excess?
        !source? && !complex? &&
          children.size == 1 && children.first.specific? && !reactant?
      end

      # Excludes current spec. Instead of the current spec replaces the parent to the
      # child and vice versa. Should have only one parent and only one child.
      # @raise [RuntimeError] if spec is not excess and not unused
      def exclude
        raise 'Excluding spec could be excess or unused' unless excess? || unused?

        parents.map(&:original).uniq.each { |parent| parent.remove_child(self) }

        return if children.empty?

        parent = parents.first.original
        children.each do |child|
          parent ? child.replace_base_spec(parent) : child.remove_parent(self)
        end
      end

      # Organize dependencies from another specs by dynamic table
      # @param [BaseSpeciesTable] table the dynamic table of species dependencies
      def organize_dependencies!(table)
        rest = table.best(self)
        store_rest(rest) unless rest == self
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
