module VersatileDiamond

  module Mcs

    class StructureMapper
      include Mcs::IntersetProjection

      class CannotMap < Exception; end

      class << self
        def map(source_links_list, product_links_list, &block)
          new(source_links_list, product_links_list).map(&block)
        end
      end

      def initialize(source_links_list, product_links_list)
        make_graphs = -> links { Graph.new(links) }
        source_graphs = source_links_list.map(&make_graphs)
        product_graphs = product_links_list.map(&make_graphs)

        define_reaction_type(source_graphs, product_graphs)
      end

      def map(&block)
        @few_graphs.sort! { |a, b| b.size <=> a.size }

        @boundary_big_vertices = nil
        @few_graphs.map do |small_graph|
          @small_graph = small_graph
          @remaining_small_vertices = nil

          big_mapped_vertices, small_mapped_vertices = find_interset

          changed_big, changed_small = if @remaining_small_vertices
            select_on_remaining(big_mapped_vertices, small_mapped_vertices)
          else
            select_on_bondary(big_mapped_vertices, small_mapped_vertices)
          end

          @boundary_big_vertices =
            @big_graph.boundary_vertices(big_mapped_vertices)
          @big_graph.remove_vertices!(big_mapped_vertices)

          associate(changed_big, changed_small, &block)
        end
      end

    private

      def define_reaction_type(source_graphs, product_graphs)
        @reaction_type = if product_graphs.size == 1 &&
          source_graphs.size > product_graphs.size

          @few_graphs, @big_graph = source_graphs, product_graphs.first
          :association
        else
          if source_graphs.size != 1
            raise ArgumentError, 'Wrong number of products and sources'
          else
            @big_graph, @few_graphs = source_graphs.first, product_graphs
            source_graphs.size < product_graphs.size ?
              :disassociation :
              :recombination
          end
        end
      end

      def find_interset
        big_mapped_vertices, small_mapped_vertices = [], []
        lattices_variants = nil

        loop do
          assoc_graph = AssocGraph.new(@big_graph, @small_graph) do |(v1, w1), (v2, w2)|
            (@boundary_big_vertices &&
              (@boundary_big_vertices.include?(v1) ||
                @boundary_big_vertices.include?(w1))) ||
            (@remaining_small_vertices &&
              (@remaining_small_vertices.include?(@small_graph.changed_vertex(v2) ||
                @remaining_small_vertices.include?(@small_graph.changed_vertex(w2)))))
          end

          interset = HanserRecursiveAlgorithm.first_interset(assoc_graph)
          raise CannotMap unless interset

          small_mapped_vertices = proj_small(interset)
          if interset.size < @small_graph.size
            # TODO: here may be situation when remaining atoms are not targeted?
            @remaining_small_vertices ||=
              @small_graph.remaining_vertices(small_mapped_vertices)

            lattices_variants ||= detect_lattices_variants
            if lattices_variants.empty?
              assoc_graph.save('assoc_error') # TODO: it's not necessarily
              raise CannotMap
            else
              new_lattices = lattices_variants.pop
              @remaining_small_vertices.zip(new_lattices).each do |atom, lattice|
                @small_graph.change_lattice!(atom, lattice)
              end
            end
          else
            big_mapped_vertices = proj_large(interset)
            break
          end
        end

        [big_mapped_vertices, small_mapped_vertices]
      end

      def detect_lattices_variants
        remaining_size = @remaining_small_vertices.size
        variants = @big_graph.lattices.repeated_permutation(remaining_size).to_a
        variants - [@remaining_small_vertices.map { |atom| atom.lattice }]
      end

      def select_on_remaining(mapped_big, mapped_small)
        small_to_big = Hash[mapped_small.zip(mapped_big)]

        # because lattice may be changed
        @remaining_small_vertices.map! do |v|
          @small_graph.vertex_changed_to(v) || v
        end

        changed_small = @remaining_small_vertices +
          @small_graph.boundary_vertices(@remaining_small_vertices)

        changed_big = changed_small.map { |v| small_to_big[v] }
        # because lattice may be changed again
        changed_small.map! { |v| @small_graph.changed_vertex(v) || v }

        [changed_big, changed_small]
      end

      def select_on_bondary(mapped_big, mapped_small)
        big_to_small = Hash[mapped_big.zip(mapped_small)]

        changed_big = if @boundary_big_vertices
            @boundary_big_vertices
          else
            # sum order is important!
            (vertices_with_differ_edges(mapped_big, big_to_small) +
              extrime_vertices(mapped_big)).uniq
          end
        changed_small = changed_big.map do |v|
          big_to_small[v]
        end

        [changed_big, changed_small]
      end

      def vertices_with_differ_edges(mapped_big, big_to_small)
        result = mapped_big.each_with_object(Set.new) do |bv, vertices|
          sv = big_to_small[bv]
          mapped_big.each do |bw|
            next if bv == bw
            sw = big_to_small[bw]

            if @big_graph.edges(bv, bw) != @small_graph.edges(sv, sw)
              vertices << bv << bw
            end
          end
        end
        result.to_a
      end

      def extrime_vertices(mapped_big)
        @big_graph.remove_edges!(mapped_big)
        @big_graph.remove_disconnected_vertices!
        @big_graph.select_vertices(mapped_big)
      end

      def associate(changed_big, changed_small, &block)
        if @reaction_type == :association
          block[@small_graph.original_links, @big_graph.original_links,
            changed_small, changed_big]
        else
          block[@big_graph.original_links, @small_graph.original_links,
            changed_big, changed_small]
        end
      end
    end

  end

end
