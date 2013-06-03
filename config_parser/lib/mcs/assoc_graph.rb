module VersatileDiamond

  class AssocGraph
    def initialize(g1, g2)
      @g1, @g2 = g1, g2

      # forbidden and existed edges
      @fbn, @ext = {}, {}

      # build association graph vertices
      @g1.each_vertex do |v|
        @g2.each_vertex do |w|
          add_vertex(v, w) if v.same?(w) #&& w.same?(v)
        end
      end

      # setup corresponding edges
      each_vertex do |v_w1|
        each_vertex do |v_w2|
          v1, w1 = v_w1
          v2, w2 = v_w2
          next if v1 == v2 && w1 == w2 # without loop at each associated vertex

          edge = [v_w1, v_w2]
          if (large_edge = @g1.edge(v1, v2)) && large_edge == @g2.edge(w1, w2)
            add_edge(@ext, *edge)
          elsif @g1.edge(v1, v2) || @g2.edge(w1, w2)
            add_edge(@fbn, *edge)
          end
        end
      end
    end

    def has_edges?
      !@ext.empty?
    end

    def vertices
      @ext.keys.to_set
    end

    %w(fbn ext).each do |vname|
      define_method(vname) do |x|
        instance_variable_get("@#{vname}".to_sym)[x].to_set
      end
    end

  private

    # Adds the couple vertices where each pair has one vertex from large_graph and second vertex from small_graph
    def add_vertex(v, w)
      vertex = [v, w]
      @fbn[vertex] ||= []
      @ext[vertex] ||= []
    end

    def add_edge(edges, v, w)
      edges[v] << w
      edges[w] << v
    end

    def each_vertex(&block)
      @ext.keys.each(&block)
    end

  end

end