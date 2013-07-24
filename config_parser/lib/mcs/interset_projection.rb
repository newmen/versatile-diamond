module VersatileDiamond

  module Mcs

    module IntersetProjection
      def proj_large(interset)
        proj(interset, :first)
      end

      def proj_small(interset)
        proj(interset, :last)
      end

      def proj(interset, index)
        interset.map(&index)
      end

      def vertices_as_str(graph, vertices)
        "[#{vertices.map { |atom| graph.atom_alias[atom] }.join(', ')}]"
      end
    end

  end

end
