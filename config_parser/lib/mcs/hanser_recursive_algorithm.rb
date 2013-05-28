module VersatileDiamond

  # Hanser's recursive algorithm search maximal common substructure (MCS).
  # General description of the algorithm on russian language could be found there:
  #   http://www.scitouch.net/downloads/mcs_article.pdf
  class HanserRecursiveAlgorithm
    class << self
      def contain?(large_links, small_links)
        large_graph = LinksWrapper.new(large_links)
        small_graph = LinksWrapper.new(small_links)

        intersets = new(large_graph, small_graph).intersets
        !intersets.empty? && intersets.first.size == small_graph.size
      end
    end

    def initialize(large_graph, small_graph)
      @large_graph, @small_graph = large_graph, small_graph

      @fbn, @ext = {}, {}

      @large_graph.each_vertex do |v|
        @small_graph.each_vertex do |w|
          add_vertex(v, w) if v.same?(w)
        end
      end

      each_vertex do |v_w1|
        each_vertex do |v_w2|
          v1, w1 = v_w1
          v2, w2 = v_w2
          next if v1 == v2 && w1 == w2 # without loop at each associated vertex

          edge = [v_w1, v_w2]
          if (large_edge = @large_graph.edge(v1, v2)) && large_edge == @small_graph.edge(w1, w2)
            add_edge(@ext, *edge)
          elsif @large_graph.edge(v1, v2) || @small_graph.edge(w1, w2)
            add_edge(@fbn, *edge)
          end
        end
      end
    end

    def intersets
      @intersets = []
      unless @ext.empty?
        @max_size = 0
        @solutions = Set.new
        @x = @ext.keys.to_set

        s = Set.new
        q_plus = @x.dup
        q_minus = Set.new

        parse_recursive(s, q_plus, q_minus)

        # filtering incorrect results
        @intersets.select! do |s|
          proj_large(s).size == @max_size && proj_small(s).size == @max_size
        end
      end

      @intersets
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

    def parse_recursive(s, q_plus, q_minus)
      if s.size > @max_size
        @max_size = s.size
        @intersets.clear
        @intersets << s
      elsif s.size == @max_size
        @intersets << s
      end

      if q_plus.empty?
        @solutions |= [s]
      else
        p = (@x - q_minus) | s

        if must_continue(p)
          (q_plus - s).each do |x|
            q_minus_n = q_minus | fbn(x)

            if s.empty?
              q_plus_n = ext(x) - q_minus_n
            else
              q_plus_n = (q_plus | ext(x)) - q_minus_n
            end

            q_minus << x

            parse_recursive(s | [x], q_plus_n, q_minus_n)
          end
        end
      end
    end

    def must_continue(p)
      @solutions.each do |s|
        if proj_large(s).subset?(proj_large(p)) || proj_small(s).subset?(proj_small(p))
          return false
        end
      end
      true
    end

    def proj_large(vertices_set)
      proj(vertices_set, :first)
    end

    def proj_small(vertices_set)
      proj(vertices_set, :last)
    end

    def proj(vertices_set, index)
      vertices_set.map(&index).to_set
    end

    def fbn(x)
      @fbn[x].to_set
    end

    def ext(x)
      @ext[x].to_set
    end
  end

end
