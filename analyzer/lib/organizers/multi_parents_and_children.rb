module VersatileDiamond
  module Organizers

    # Describes dependent instance which could have parents and children
    module MultiParentsAndChildren
      extend Organizers::Collector

      collector_methods :parent, :child

    protected

      # Stores the parent of reaction
      # @param [DependentReaction] parent the parent of current reaction
      alias_method :super_store_parent, :store_parent
      def store_parent(parent)
        super_store_parent(parent)
        parent.store_child(self)
      end
    end

  end
end
