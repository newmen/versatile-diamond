module VersatileDiamond
  module Mcs

    # Presents projection of intersec to some graph
    module IntersecProjection

      # Makes projection for the first graph of used algorithm
      # @param [Array] intersec the projecting inteset
      # @return [Array] the array of vertices of first graph
      def proj_large(intersec)
        proj(intersec, :first)
      end

      # Makes projection for the second graph of used algorithm
      # @param [Array] intersec see at #proj_large same argument
      # @return [Array] the array of vertices of second graph
      def proj_small(intersec)
        proj(intersec, :last)
      end

      def vertices_as_str(graph, vertices)
        "[#{vertices.map { |atom| graph.atom_alias[atom] }.join(', ')}]"
      end

    private

      # Applies index method name to each pair of vertices from intersec
      # @param [Array] intersec see at #proj_large same argument
      # @param [Symbol] index the name of method that applying to each pair of
      #   vertices from intersec
      # @return [Array] the array of vertices
      def proj(intersec, index)
        intersec.map(&index)
      end

    end

  end
end
