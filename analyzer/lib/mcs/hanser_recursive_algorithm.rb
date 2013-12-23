module VersatileDiamond
  module Mcs

    # Hanser's recursive algorithm search maximal common substructure (MCS).
    # General description of the algorithm on russian language could be found
    # there: http://www.scitouch.net/downloads/mcs_article.pdf
    class HanserRecursiveAlgorithm
      include Mcs::IntersetProjection

      class << self
        # Checks contents of the second (small) link in the first (large)
        # @param [Hash] large_links links of structure in which to search
        # @param [Hash] small_links links that search will be carried out
        # @option [Boolean] :separated_multi_bond set to true if need separated
        #   instances for double or triple bonds
        # @raise [RuntimeError] if some of separated multi-bonds is invalid
        # @return [Boolean] contain or not
        def contain?(large_links, small_links, separated_multi_bond: false)
          large_graph = Graph.new(large_links,
            separated_multi_bond: separated_multi_bond)
          small_graph = Graph.new(small_links,
            separated_multi_bond: separated_multi_bond)
          assoc_graph = AssocGraph.new(large_graph, small_graph)

          interset = first_interset(assoc_graph)
          interset && interset.size == small_graph.size
        end

        # Finds first interset in passed association graph
        # @param [AssocGraph] assoc_graph the association graph in which search
        #   will be carried out
        # @return [Array] the first intersection
        def first_interset(assoc_graph)
          new(assoc_graph).intersets.first
        end
      end

      # Initialize an instance by association graph
      # @param [AssocGraph] assoc_graph see at #self.first_interset same arg
      def initialize(assoc_graph)
        @assoc_graph = assoc_graph
      end

      # Finds all intersets of associated structures. Once all possible
      # intersections are found, are selected only those projections of that
      # correspond to associated structures.
      def intersets
        @intersets = []

        @max_size = 0
        @x = @assoc_graph.vertices

        s = Set.new
        q_plus = @x.dup
        q_minus = Set.new

        parse_recursive(s, q_plus, q_minus)

        # filtering incorrect results
        @intersets.select do |interset|
          proj_large(interset).size == @max_size &&
            proj_small(interset).size == @max_size
        end
      end

    private

      # Modified Hanser's recursive function that searches for cliques in the
      # association graph. All found solutions will be stored to intersets var.
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
          @intersets.clear
          @intersets << s
        elsif s.size == @max_size
          @intersets << s
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
