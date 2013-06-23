require 'graphviz'

module VersatileDiamond

  class AssocGraph
    def initialize(g1, g2, &block)
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
      cache = EdgeCache.new
      each_vertex do |v_v|
        each_vertex do |w_w|
          v1, v2 = v_v
          w1, w2 = w_w
          next if v1 == w1 && v2 == w2 # without loop at each associated vertex

          edge = [v_v, w_w]
          next if cache.has?(*edge) # without reverse edges
          cache.add(*edge)

          e1 = @g1.edge(v1, w1)
          e2 = @g2.edge(v2, w2)

          if e1 && e2 && (e1 == e2 || (block_given? && block[[v1, w1], [v2, w2]] && e1.same?(e2)))
            add_edge(@ext, *edge)
          elsif e1 || e2 || v1 == w1 || v2 == w2
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

    def save(filename, ext = 'png')
      save_for(@ext, 'ext')
      # save_for(@fbn, 'fbn')
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

    def save_for(edges, prefix)
      g = GraphViz.new(:C, type: :graph)
      cache = EdgeCache.new
      edges.each do |v_v, list|
        v1, v2 = v_v
        list.each do |w_w|
          next if cache.has?(v_v, w_w)
          cache.add(v_v, w_w)

          w1, w2 = w_w
          g.add_edges("#{@g1.atom_alias[v1]}_#{@g2.atom_alias[v2]}", "#{@g1.atom_alias[w1]}_#{@g2.atom_alias[w2]}")
        end
      end
      g.output(ext.to_sym => "#{prefix}_#{filename}.#{ext}")
    end

  end

end