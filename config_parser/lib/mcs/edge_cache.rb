module VersatileDiamond
  module Mcs

    # The instance of class serve for edges caching and checks edge existing
    # in forward and reverse directions
    class EdgeCache

      # Inits internal cache variable
      def initialize
        @cache = {}
      end

      # Adds new edge to cache
      # @param [Concepts::Atom] v the first vertex
      # @param [Concepts::Atom] w the second vertex
      def add(v, w)
        @cache[v] ||= Set.new
        @cache[v] << w
      end

      # Checks edge existing between two vertices
      # @param [Concepts::Atom] v see at #add same argument
      # @param [Concepts::Atom] w see at #add same argument
      def has?(v, w)
        (@cache[v] && @cache[v].include?(w)) ||
          (@cache[w] && @cache[w].include?(v))
      end
    end

  end
end
