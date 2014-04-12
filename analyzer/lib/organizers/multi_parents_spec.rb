module VersatileDiamond
  module Organizers

    # Also conatins parents
    module MultiParentsSpec
      extend Organizers::DisposedCollector

      collector_methods :parent

      # Stores the one of parent of current spec and inserts child link to self spec to
      # parent spec
      #
      # @param [DependentBaseSpec] parent the one of parent of current spec
      # @override
      alias_method :super_store_parent, :store_parent
      def store_parent(parent)
        super_store_parent(parent)
        parent.store_child(self)
      end
    end

  end
end