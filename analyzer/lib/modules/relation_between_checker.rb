module VersatileDiamond
  module Modules

    # Provides method for find relation between two vertices
    module RelationBetweenChecker
      # Gets relation between passed vertices
      # @param [Object] first vertex
      # @param [Object] second vertex
      # @return [Bond] relation between vertices or nil if relation is not presented
      def relation_between(first, second)
        rels = links[first]
        pair = rels.find { |v, _| v == second } if rels
        pair && pair.last
      end
    end

  end
end
