module VersatileDiamond

  class Graph
    def initialize(links)
      @edges = links
    end

    def each_vertex(&block)
      @edges.keys.each(&block)
    end

    def edge(v, w)
      @edges[v] && (edge = @edges[v].find { |vertex, _| vertex == w }) && edge.last
    end
  end

end
