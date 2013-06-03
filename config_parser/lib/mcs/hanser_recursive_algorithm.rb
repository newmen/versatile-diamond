module VersatileDiamond

  # Hanser's recursive algorithm search maximal common substructure (MCS).
  # General description of the algorithm on russian language could be found there:
  #   http://www.scitouch.net/downloads/mcs_article.pdf
  class HanserRecursiveAlgorithm
    class << self
      def contain?(large_links, small_links)
        intersets = new(large_links, small_links).intersets
        !intersets.empty? && intersets.first.size == small_links.size
      end
    end

    def initialize(large_links, small_links)
      @assoc_graph = AssocGraph.new(Graph.new(large_links), Graph.new(small_links))
    end

    def intersets
      @intersets = []
      if @assoc_graph.has_edges?
        @max_size = 0
        @solutions = Set.new
        @x = @assoc_graph.vertices

        s = Set.new
        q_plus = @x.dup
        q_minus = Set.new

        parse_recursive(s, q_plus, q_minus)

        # filtering incorrect results
        @intersets.select! do |interset|
          proj_large(interset).size == @max_size && proj_small(interset).size == @max_size
        end
      end

      @intersets
    end

  private

    def parse_recursive(s, q_plus, q_minus)
      # store current solution if it has max number of association vertices
      if s.size > @max_size
        @max_size = s.size
        @intersets.clear
        @intersets << s
      elsif s.size == @max_size
        @intersets << s
      end

      # clicue finding algorithm
      if q_plus.empty?
        @solutions += [s]
      else
        p = (@x - q_minus) + s

        if must_continue(p)
          (q_plus - s).each do |x|
            q_minus_n = q_minus + @assoc_graph.fbn(x)

            if s.empty?
              q_plus_n = @assoc_graph.ext(x) - q_minus_n
            else
              q_plus_n = (q_plus + @assoc_graph.ext(x)) - q_minus_n
            end

            q_minus << x

            parse_recursive(s + [x], q_plus_n, q_minus_n)
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
  end

end
