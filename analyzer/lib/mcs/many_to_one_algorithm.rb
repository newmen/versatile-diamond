module VersatileDiamond
  module Mcs

    # An instance of this class is designed for the mapping of the two
    # structures into one (or vice versa). Mapping is carried out using
    # Hanser's algorithm. Since the Hanser's algorithm works through an
    # associated graph, then to build it, investigated properties of graphs
    # are taken into account in addition as the presence of overlap of the
    # crystal lattice. Under the impact of lattice the atoms neighborhood
    # concept appears in one of the crystal planes defined by Miller indices,
    # and hence there is a large number of types of connecting edges. Moreover,
    # the double bond is not a bond of some other type - it's just two bonds.
    # Atoms may belong (or not belong) crystal lattice, break and form of
    # communication, maintaining its relative position.
    # Also finds only changed atoms.
    class ManyToOneAlgorithm
      include Modules::ListsComparer
      include IntersecProjection

      class << self
        # Maps two structures to one (or vice versa) and pass result of
        # mapping to mapping result object
        #
        # @param [MappingResult] map_result the object which accumulate mapping
        #   result
        # @raise [AtomMapper::CannotMap] when algorithm cannot be applied
        def map_to(map_result)
          new(map_result.source, map_result.products,
            map_result.reaction_type).map_to(map_result)
        end
      end

      # Initialize an instance by setuping source and product graphs for the
      # algorithm. Detects the reaction type: assocation, dissocation or
      # recombination.
      #
      # @param [Array] sources the list of source species
      # @param [Array] products the list of products species
      # @param [Symbol] reaction_type the type of reaction (association or
      #   dissociation)
      def initialize(source, products, reaction_type)
        make_graphs = -> spec { Graph.new(spec) }
        source_graphs = source.map(&make_graphs)
        product_graphs = products.map(&make_graphs)

        @graphs_to_specs = {}
        @graphs_to_specs.merge!(Hash[source_graphs.zip(source)])
        @graphs_to_specs.merge!(Hash[product_graphs.zip(products)])

        # must be :association or :dissociation for current algorithm
        @reaction_type = reaction_type

        @few_graphs, @big_graph =
          if @reaction_type == :association
            [source_graphs, product_graphs.first]
          else
            [product_graphs, source_graphs.first]
          end
      end

      # Maps structures from stored graphs and associate_links they vertices by
      # passed block. Maximum Common Substructure searching between each of
      # lower structures (their descending size) and larger structure
      # determines by Hanser's algorithm. Upon receipt of the projected
      # intersection of the corresponding atoms in both structures, and fully
      # checked whether the resulting intersection covers a smaller structure.
      # If not then it is determined what types of atoms at the structure
      # changed. Otherwise, by larger structure define what atoms have changed
      # their attitude to the atoms of the second of the smaller structures.
      # After the overlay a lesser structure will delete all associated atoms
      # from the larger structure.
      #
      # @param [MappingResult] map_result see at #self.map same argument
      # @raise [AtomMapper::CannotMap] see at #self.map
      def map_to(mapping_result)
        @few_graphs.sort! { |a, b| b.size <=> a.size }

        @boundary_big_vertices = nil
        @few_graphs.each do |small_graph|
          @small_graph = small_graph
          @remaining_small_vertices = nil

          big_mapped_vertices, small_mapped_vertices = find_intersec

          changed_big, changed_small =
            if @remaining_small_vertices
              select_on_remaining(big_mapped_vertices, small_mapped_vertices)
            else
              select_on_bondary(big_mapped_vertices, small_mapped_vertices)
            end

          @boundary_big_vertices = @big_graph.boundary_vertices(big_mapped_vertices)
          @big_graph.remove_vertices!(big_mapped_vertices)

          # exchange to original atom for full atom mapping result
          small_mapped_vertices.map! do |v|
            @small_graph.changed_vertex(v) || v
          end

          # store result
          changes = associate_links(changed_big, changed_small)
          full = associate_links(big_mapped_vertices, small_mapped_vertices)
          mapping_result.add(associate_specs, full, changes)
        end
      end

    private

      # In order to handle situations change atom accessories to crystal
      # lattice, well as the possibility change the position of the atoms
      # relative to each other - an additional condition imposed on the
      # construction of associative graph over which produced search
      # mismatching of the structures. Permutates all the possible alteration
      # of belonging to each of the lattice atoms, which could not be mapped.
      #
      # @raise [AtomMapper::CannotMap] see at #self.map
      # @return [Array, Array] interseced vertices of both source and product
      #   graphs
      def find_intersec
        big_mapped_vertices, small_mapped_vertices = [], []
        lattices_variants = nil

        loop do
          assoc_graph = build_assoc_graph

          intersec = HanserRecursiveAlgorithm.first_intersec(assoc_graph)
          raise AtomMapper::CannotMap unless intersec

          small_mapped_vertices = proj_small(intersec)
          if intersec.size < @small_graph.size
            # TODO: here may be situation when remaining atoms are not targeted?
            @remaining_small_vertices ||=
              @small_graph.remaining_vertices(small_mapped_vertices)

            lattices_variants ||= detect_lattices_variants

            if lattices_variants.empty?
              # assoc_graph.save('assoc_error') # TODO: it's not necessarily
              raise AtomMapper::CannotMap
            else
              new_lattices = lattices_variants.pop
              @remaining_small_vertices.zip(new_lattices).each do |atom, lattice|
                @small_graph.change_lattice!(atom, lattice)
              end
            end
          else
            big_mapped_vertices = proj_large(intersec)
            break
          end
        end

        [big_mapped_vertices, small_mapped_vertices]
      end

      # Builds associaton graph with addition condition for creates bonds of
      # both types in association graph
      #
      # @return [AssocGraph] the resulted associaton graph
      def build_assoc_graph
        bbvs = @boundary_big_vertices
        rsvs = @remaining_small_vertices

        opts = {
          comparer: method(:vertex_comparer),
          bonds_checker: method(:can_bond?)
        }

        AssocGraph.new(@big_graph, @small_graph, **opts) do |(v1, v2), (w1, w2)|
          (bbvs && (bbvs.include?(v1) || bbvs.include?(v2))) ||
          (rsvs &&
            (rsvs.include?(@small_graph.changed_vertex(w1) ||
              rsvs.include?(@small_graph.changed_vertex(w2)))))
        end
      end

      # @param [Array] atoms
      # @return [Boolean]
      def can_bond?(*atoms)
        atoms.all? { |a| a.actives > 0 }
      end

      # Compare two vertices in different graphs for creating associated vertex
      # in associaton graph
      #
      # @param [Graph] g1 the first graph
      # @param [Graph] g2 the second graph
      # @param [Concepts::Atom | Concepts::SpecificAtom] v atom of first graph
      # @param [Concepts::Atom | Concepts::SpecificAtom] w atom of second graph
      # @return [Boolean] is vertices equal
      def vertex_comparer(g1, g2, v, w)
        # valence is not compared because could not be case when names is equal
        # and valencies is not
        return false unless v.name == w.name && v.lattice == w.lattice

        cmp = (@boundary_big_vertices && @boundary_big_vertices.include?(v)) ||
          (@remaining_small_vertices &&
            @remaining_small_vertices.include?(g2.changed_vertex(w)))
        return true if cmp

        s1, s2 = @graphs_to_specs[g1], @graphs_to_specs[g2]
        cv, cw = g1.changed_vertex(v) || v, g2.changed_vertex(w) || w

        s1.external_bonds_for(cv) == s2.external_bonds_for(cw)
      end

      # Defines the possible variants for changing accessories to the crystal
      # lattice of atoms
      #
      # @return [Array] the array of arrays of lattices variants
      def detect_lattices_variants
        remaining_size = @remaining_small_vertices.size
        variants = @big_graph.lattices.repeated_permutation(remaining_size).to_a
        variants - [@remaining_small_vertices.map { |atom| atom.lattice }]
      end

      # Defines changed vertices for both graphs by selecting from remaining
      # small vertices
      #
      # @return [Array, Array] changed vertices for both graphs
      def select_on_remaining(mapped_big, mapped_small)
        small_to_big = Hash[mapped_small.zip(mapped_big)]
        big_to_small = small_to_big.invert

        # because lattice may be changed
        @remaining_small_vertices.map! do |v|
          @small_graph.vertex_changed_to(v) || v
        end

        remaining_big = @remaining_small_vertices.map { |v| small_to_big[v] }
        boundary_big = @big_graph.boundary_vertices(remaining_big)
        pairs = boundary_big.map { |v| [v, big_to_small[v]] }.select(&:last)
        different_pairs = pairs.select { |v, w| !v.same?(w) || realy_changed?(v, w) }
        different_small = different_pairs.map(&:last)

        boundary_small = @small_graph.boundary_vertices(@remaining_small_vertices)
        changed_small =
          (@remaining_small_vertices + boundary_small + different_small).uniq

        changed_big = changed_small.map { |v| small_to_big[v] }
        # because lattice may be changed again
        changed_small.map! { |v| @small_graph.changed_vertex(v) || v }

        [changed_big, changed_small]
      end

      # Defines changed vertices for both graphs by selecting from boundary
      # big vertices
      #
      # @return [Array, Array] changed vertices for both graphs
      def select_on_bondary(mapped_big, mapped_small)
        big_to_small = Hash[mapped_big.zip(mapped_small)]
        small_to_big = big_to_small.invert

        changed_big = @boundary_big_vertices ||
            # sum order is important!
            (vertices_with_differ_edges(mapped_big, big_to_small) +
              extreme_vertices!(mapped_big)).uniq

        changed_small = changed_big.map { |v| big_to_small[v] }.compact
        changed_small.select! { |v| realy_changed?(small_to_big[v], v) }

        [changed_small.map { |v| small_to_big[v] }, changed_small]
      end

      # Checks that passed vertices is realy different
      # @param [Concepts::Atom] big_vertex the vertex from big graph
      # @param [Concepts::Atom] small_vertex the vertex from small graph
      # @return [Boolean] are different atoms or not
      def realy_changed?(big_vertex, small_vertex)
        return true if big_vertex.lattice != small_vertex.lattice

        big_edges = @big_graph.significant_edges_of(big_vertex)
        small_edges = @small_graph.significant_edges_of(small_vertex)
        !lists_are_identical?(big_edges, small_edges)
      end

      # Determines which vertices changed by changing the relative position or
      # the form-drop bond.
      #
      # @param [Array] mapped_big the mapped vertices of big graph
      # @param [Hash] big_to_small the mirror of vertices from big to small
      #   graph
      # @return [Array] the set of changed vertices from big graph
      def vertices_with_differ_edges(mapped_big, big_to_small)
        result = mapped_big.each_with_object(Set.new) do |bv, vertices|
          sv = big_to_small[bv]
          mapped_big.each do |bw|
            next if bv == bw
            sw = big_to_small[bw]

            big_edges = @big_graph.edges(bv, bw)
            small_edges = @small_graph.edges(sv, sw)
            vertices << bv << bw unless lists_are_identical?(big_edges, small_edges)
          end
        end
        result.to_a
      end

      # Reduces the big graph by removing edges and disconnected vertices
      # @return [Array] the array of extreme vertices
      def extreme_vertices!(mapped_big)
        @big_graph.remove_edges!(mapped_big)
        @big_graph.remove_disconnected_vertices!
        @big_graph.select_vertices(mapped_big)
      end

      # Gets associaing specis in correct order
      # @return [Array] the array of associating species
      def associate_specs
        big_spec = @graphs_to_specs[@big_graph]
        small_spec = @graphs_to_specs[@small_graph]

        if @reaction_type == :association
          [small_spec, big_spec]
        else
          [big_spec, small_spec]
        end
      end

      # Associate changed vertices with each other
      # @param [Array] changed_big the changed not specified atoms of big spec
      # @param [Array] changed_small the changed not specified atoms of small
      #   spec
      # @return [Array] depending from type of reaction, return parameters in
      #   correct order
      def associate_links(changed_big, changed_small)
        if @reaction_type == :association
          [changed_small, changed_big]
        else
          [changed_big, changed_small]
        end
      end
    end

  end
end
