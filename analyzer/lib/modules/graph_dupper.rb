module VersatileDiamond
  module Modules

    # Provides methods for creating the graph duplication
    module GraphDupper
    private

      # Creates the duplication of passed graph
      # @param [Hash] graph which will be duplicated
      # @yield [Object] the block by which each vertex will be duplicated or Object#dup
      #   by default
      # @return [Hash] the duplication
      def dup_graph(graph, &block)
        graph.each_with_object({}) do |(v, rels), acc|
          acc[dup_vertex(v, &block)] = rels.map do |w, r|
            [dup_vertex(w, &block), r]
          end
        end
      end

      # Duplicates the vertex of graph
      # @param [Object] vertex which will be duplicated
      # @yield [Object] the block by which the passed vertex will be duplicated or
      #   will be used Object#dup by default
      def dup_vertex(vertex, &block)
        if block_given?
          block[vertex]
        else
          vertex.is_a?(Symbol) ? vertex : vertex.dup
        end
      end
    end

  end
end
