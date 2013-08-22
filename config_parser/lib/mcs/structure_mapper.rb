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
    # Finds only changed atoms.
    class StructureMapper
      include Mcs::IntersetProjection

      # Exception for cannot map case
      class CannotMap < Exception; end

      class << self
        # Maps two structures to one (or vice versa) and return result of
        # mapping in passed block
        #
        # @param [Array] source_links_list the list of source graphs
        # @param [Array] product_links_list the list of product graphs
        # @yeild [Hash, Hash, Array, Array] receives two graphs (in the order
        #   corresponding to calling this method) and two arrays of vertices
        #   that have been changed in the corresponding graphs
        # @raise [CannotMap] when algorithm cannot be applied
        # @return [Array] the structure atom mapping result
        def map(source_links_list, product_links_list, &block)
          new(source_links_list, product_links_list).map(&block)
        end
      end

      # Initialize an instance by setuping source and product graphs for the
      # algorithm. Detects the reaction type: assocation, dissocation or
      # recombination.
      #
      # @param [Array] source_links_list see at #self.map same argument
      # @param [Array] product_links_list see at #self.map same argument
      def initialize(source_links_list, product_links_list)
        make_graphs = -> links { Graph.new(links) }
        source_graphs = source_links_list.map(&make_graphs)
        product_graphs = product_links_list.map(&make_graphs)

        define_reaction_type(source_graphs, product_graphs)
      end

      # Maps structures from stored graphs and associate they vertices by
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
      # @yield [Hash, Hash, Array, Array] see at #self.map same argument
      # @raise [CannotMap] see at #self.map
      # @return [Array] the structure atom mapping result with two elements:
      #   the first is full mapping result and the second just changed mapping
      #   result
      def map(&block)
        @few_graphs.sort! { |a, b| b.size <=> a.size }

        @boundary_big_vertices = nil
        changed_map = []
        full_map = @few_graphs.map do |small_graph|
          @small_graph = small_graph
          @remaining_small_vertices = nil

          big_mapped_vertices, small_mapped_vertices = find_interset

          changed_big, changed_small = if @remaining_small_vertices
              select_on_remaining(big_mapped_vertices, small_mapped_vertices)
            else
              select_on_bondary(big_mapped_vertices, small_mapped_vertices)
            end
          changed_map << associate(changed_big, changed_small, &block)

          @boundary_big_vertices =
            @big_graph.boundary_vertices(big_mapped_vertices)
          @big_graph.remove_vertices!(big_mapped_vertices)

          # exchange to original atom for full atom mapping result
          small_mapped_vertices.map! do |v|
            @small_graph.changed_vertex(v) || v
          end
          associate(big_mapped_vertices, small_mapped_vertices, &block)
        end

        [full_map, changed_map]
      end

    private

      # Defines and store reaction type and stores passed graph to correspond
      # internal graphs
      #
      # @param [Array] source_graphs see at #self.map source_links_list arg
      # @param [Array] product_graphs see at #self.map product_links_list arg
      # @raise [CannotMap] see at #self.map
      def define_reaction_type(source_graphs, product_graphs)
        @reaction_type = if product_graphs.size == 1 &&
          source_graphs.size > product_graphs.size

          @few_graphs, @big_graph = source_graphs, product_graphs.first
          :association
        else
          if source_graphs.size != 1
            raise CannotMap, 'Wrong number of products and sources'
          else
            @big_graph, @few_graphs = source_graphs.first, product_graphs
            source_graphs.size < product_graphs.size ?
              :disassociation :
              :recombination
          end
        end
      end

      # In order to handle situations change atom accessories to crystal
      # lattice, well as the possibility change the position of the atoms
      # relative to each other - an additional condition imposed on the
      # construction of associative graph over which produced search
      # mismatching of the structures. Permutates all the possible alteration
      # of belonging to each of the lattice atoms, which could not be mapped.
      #
      # @raise [CannotMap] see at #self.map
      # @return [Array, Array] interseted vertices of both source and product
      #   graphs
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

      # Defines changed vertices for both graphs by selecting from boundary
      # big vertices
      #
      # @return [Array, Array] changed vertices for both graphs
      def select_on_bondary(mapped_big, mapped_small)
        big_to_small = Hash[mapped_big.zip(mapped_small)]

        changed_big = if @boundary_big_vertices
            @boundary_big_vertices
          else
            # sum order is important!
            (vertices_with_differ_edges(mapped_big, big_to_small) +
              extreme_vertices(mapped_big)).uniq
          end
        changed_small = changed_big.map { |v| big_to_small[v] }

        [changed_big, changed_small]
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

            if @big_graph.edges(bv, bw) != @small_graph.edges(sv, sw)
              vertices << bv << bw
            end
          end
        end
        result.to_a
      end

      # Reduces the big graph by removing edges and disconnected vertices
      # @return [Array] the array of extreme vertices
      def extreme_vertices(mapped_big)
        @big_graph.remove_edges!(mapped_big)
        @big_graph.remove_disconnected_vertices!
        @big_graph.select_vertices(mapped_big)
      end

      # Associate changed vertices with each other by passed block
      # @yeild [Hash, Hash, Array, Array] used in #self.map, and depending from
      #   type of reaction passes parameters to block in the correct order
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
