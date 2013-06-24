module VersatileDiamond

  # Hanser's recursive algorithm search maximal common substructure (MCS).
  # General description of the algorithm on russian language could be found
  # there: http://www.scitouch.net/downloads/mcs_article.pdf
  class HanserRecursiveAlgorithm

    class CannotMap < Exception; end

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

    class << self
      def contain?(large_links, small_links)
        large_graph = Graph.new(large_links)
        small_graph = Graph.new(small_links)
        intersets = new(large_graph, small_graph).intersets
        !intersets.empty? && intersets.first.size == small_graph.size
      end

      def atom_mapping(source_links, product_links, &block)
        make_graphs = -> links { Graph.new(links) }
        source_graphs = source_links.map(&make_graphs)
        product_graphs = product_links.map(&make_graphs)

        reaction_type = nil
        if product_graphs.size == 1 &&
          source_graphs.size > product_graphs.size

          few_graphs, big_graph = source_graphs, product_graphs.first
          reaction_type = :association
        else
          if source_graphs.size != 1
            raise ArgumentError, 'Wrong number of products and sources'
          else
            big_graph, few_graphs = source_graphs.first, product_graphs
            source_graphs.size < product_graphs.size ?
              :disassociation :
              :recombination
          end
        end

        associate = -> big, small, changed_big, changed_small do
          if reaction_type == :association
            block[small.original_links, big.original_links,
              changed_small, changed_big]
          else
            block[big.original_links, small.original_links,
              changed_big, changed_small]
          end
        end

        few_graphs.sort! { |a, b| b.size <=> a.size }

        boundary_big_vertices = nil
        few_graphs.map do |small_graph|
          big_mapped_vertices, small_mapped_vertices = [], []
          remaining_small_vertices, lattices_variants = nil

          loop do
            algorithm = new(big_graph, small_graph) do |(v1, w1), (v2, w2)|
              (boundary_big_vertices && (boundary_big_vertices.include?(v1) || boundary_big_vertices.include?(w1))) ||
                (remaining_small_vertices &&
                  (remaining_small_vertices.include?(small_graph.changed_vertex(v2) ||
                    remaining_small_vertices.include?(small_graph.changed_vertex(w2)))))
            end

            interset = algorithm.intersets.first
            raise CannotMap unless interset
            small_mapped_vertices = proj_small(interset)

            if interset.size < small_graph.size
              # TODO: here may be situation when remaining atoms are
              # not targeted
              remaining_small_vertices ||=
                small_graph.remaining_vertices(small_mapped_vertices)

              unless lattices_variants
                remaining_size = remaining_small_vertices.size
                lattices_variants = big_graph.lattices.
                  repeated_permutation(remaining_size).to_a
                current_lattices = remaining_small_vertices.map do |atom|
                  atom.lattice
                end
                lattices_variants -= [current_lattices]
              end

              if lattices_variants.empty?
                algorithm.save('assoc_error') # TODO: it's not necessarily
                raise CannotMap
              else
                new_lattices = lattices_variants.pop
                remaining_small_vertices.zip(new_lattices).each do |atom, lattice|
                  small_graph.change_lattice!(atom, lattice)
                end
              end
            else
              big_mapped_vertices = proj_large(interset)
              break
            end
          end

          if remaining_small_vertices
            remaining_small_vertices.map! do |v|
              # because lattice may be changed
              small_graph.vertex_changed_to(v) || v
            end

            changed_small_vertices = remaining_small_vertices +
              small_graph.boundary_vertices(remaining_small_vertices)
            small_to_big = Hash[small_mapped_vertices.zip(big_mapped_vertices)]

            changed_big_vertices = changed_small_vertices.map do |v|
              small_to_big[v]
            end
            changed_small_vertices.map! do |v|
              # because lattice may be changed too
              small_graph.changed_vertex(v) || v
            end
          else
            big_to_small = Hash[big_mapped_vertices.zip(small_mapped_vertices)]
            changed_big_vertices = if boundary_big_vertices
                boundary_big_vertices
              else
                vertices_with_another_edges = Set.new
                big_mapped_vertices.each do |bv|
                  sv = big_to_small[bv]
                  big_mapped_vertices.each do |bw|
                    next if bv == bw
                    sw = big_to_small[bw]

                    if big_graph.edges(bv, bw) != small_graph.edges(sv, sw)
                      vertices_with_another_edges << bv << bw
                    end
                  end
                end

                big_graph.remove_edges!(big_mapped_vertices)
                big_graph.remove_disconnected_vertices!

                (big_graph.select_vertices(big_mapped_vertices) +
                  vertices_with_another_edges.to_a).uniq
              end
            changed_small_vertices = changed_big_vertices.map do |v|
              big_to_small[v]
            end
          end

          boundary_big_vertices =
            big_graph.boundary_vertices(big_mapped_vertices)
          big_graph.remove_vertices!(big_mapped_vertices)

          associate[big_graph, small_graph,
            changed_big_vertices, changed_small_vertices]
        end
      end

    private

      include IntersetProjection

    end

    def initialize(large_graph, small_graph, &block)
      @assoc_graph = AssocGraph.new(large_graph, small_graph, &block)
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

    def save(filename)
      @assoc_graph.save(filename)
    end

  private

    include IntersetProjection

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
