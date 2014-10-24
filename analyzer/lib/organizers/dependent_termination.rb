module VersatileDiamond
  module Organizers

    # Contain some termination spec and set of dependent specs
    class DependentTermination < DependentSpec

      def_delegator :spec, :terminations_num
      collector_methods :parent

      # Stores the parent of current spec and inserts current instance as a child to
      # parent spec
      #
      # @param [DependentBaseSpec] parent the one of parent of current spec
      # @override
      alias_method :super_store_parent, :store_parent
      def store_parent(parent)
        super_store_parent(parent)
        parent.store_child(self)
      end

      # Termination spec always is termination
      # @return [Boolean] true
      # @override
      def termination?
        true
      end

      def to_s
        name
      end

      def inspect
        to_s
      end
    end

  end
end
