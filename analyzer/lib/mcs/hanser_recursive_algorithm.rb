module VersatileDiamond
  module Mcs

    # Hanser's recursive algorithm search maximal common substructure (MCS).
    # General description of the algorithm on russian language could be found
    # there: http://www.scitouch.net/downloads/mcs_article.pdf
    class HanserRecursiveAlgorithm
      include Mcs::IntersecProjection

      class << self
        # Finds first intersection in passed association graph
        # @param [AssocGraph] assoc_graph the association graph in which search
        #   will be carried out
        # @return [Set] the first intersection
        def first_intersec(assoc_graph)
          new(assoc_graph).intersec.first
        end
      end

      # Initialize an instance by association graph
      # @param [AssocGraph] assoc_graph see at #self.intersec same arg
      def initialize(assoc_graph)
        @assoc_graph = assoc_graph
      end

      # Finds all intersection of associated structures. Once all possible
      # intersections are found, are selected only those projections of that
      # correspond to associated structures.
      def intersec
        @intersec = []

        @max_size = 0
        @x = @assoc_graph.vertices

        s = Set.new
        q_plus = @x.dup
        q_minus = Set.new

        parse_recursive(s, q_plus, q_minus)

        # filtering incorrect results
        @intersec.select do |intersec|
          proj_large(intersec).size == @max_size &&
            proj_small(intersec).size == @max_size
        end
      end

    private

      # Modified Hanser's recursive function that searches for cliques in the
      # association graph. All found solutions will be stored to intersection var.
      #
      # @param [Set] s the set of vertices which belongs to clique
      # @param [Set] q_plus the set of vertices through which clique can be
      #   increased
      # @param [Set] q_minus the set of vertices through which search of clique
      #   is imposible
      def parse_recursive(s, q_plus, q_minus)
        # store current solution if it has max number of association vertices
        if s.size > @max_size
          @max_size = s.size
          @intersec.clear
          @intersec << s
        elsif s.size == @max_size
          @intersec << s
        end

        # simplified clique searching algorithm
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
end
