module VersatileDiamond
  module Mcs

    # Presents projection of interset to some graph
    module IntersetProjection

      # Makes projection for the first graph of used algorithm
      # @param [Array] interset the projecting inteset
      # @return [Array] the array of vertices of first graph
      def proj_large(interset)
        proj(interset, :first)
      end

      # Makes projection for the second graph of used algorithm
      # @param [Array] interset see at #proj_large same argument
      # @return [Array] the array of vertices of second graph
      def proj_small(interset)
        proj(interset, :last)
      end

      def vertices_as_str(graph, vertices)
        "[#{vertices.map { |atom| graph.atom_alias[atom] }.join(', ')}]"
      end

    private

      # Applies index method name to each pair of vertices from interset
      # @param [Array] interset see at #proj_large same argument
      # @param [Symbol] index the name of method that applying to each pair of
      #   vertices from interset
      # @return [Array] the array of vertices
      def proj(interset, index)
        interset.map(&index)
      end

    end

  end
end
