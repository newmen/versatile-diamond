module VersatileDiamond

  # Hanser's recursive algorithm search maximal common substructure (MCS).
  # General description of the algorithm on russian language could be found
  # there: http://www.scitouch.net/downloads/mcs_article.pdf
  class HanserRecursiveAlgorithm

    include IntersetProjection

    class << self
      def contain?(large_links, small_links)
        large_graph = Graph.new(large_links)
        small_graph = Graph.new(small_links)
        assoc_graph = AssocGraph.new(large_graph, small_graph)

        interset = first_interset(assoc_graph)
        interset && interset.size == small_graph.size
      end

      def first_interset(assoc_graph)
        new(assoc_graph).intersets.first
      end
    end

    def initialize(assoc_graph)
      @assoc_graph = assoc_graph
    end

    def intersets
      @intersets = []
      if @assoc_graph.has_edges?
        @max_size = 0
        @x = @assoc_graph.vertices

        s = Set.new
        q_plus = @x.dup
        q_minus = Set.new

        parse_recursive(s, q_plus, q_minus)

        # filtering incorrect results
        @intersets.select! do |interset|
          proj_large(interset).size == @max_size &&
            proj_small(interset).size == @max_size
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
      unless q_plus.empty?
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

end
