module VersatileDiamond
  module Mcs

    # Compares two specs by it links and get intersection of them.
    # Adapter for HanserRecursiveAlgorithm for using in concept species
    class SpeciesComparator
      class << self
        # Checks contents of the second spec in the first
        # @param [Hash] first see at #self.intersection same argument
        # @param [Hash] second see at #self.intersection same argument
        # @option [Boolean] :collaps_multi_bond see at #self.intersection same
        #   argument
        # @return [Boolean] contain or not
        def contain?(first, second, **options)
          return true if first.object_id == second.object_id

          traversal = intersec(first, second, options).first
          traversal && traversal.size == second.links.size
        end

        # Gets all intersection between large links hash small links hashes
        # @param [Hash] first links of structure in which to search
        # @param [Hash] second links that search will be carried out
        # @option [Boolean] :collaps_multi_bond set to true if need separated
        #   instances for double or triple bonds
        # @yeild [Graph, Graph, Concepts::Atom, Concepts::Atom] if presented compares
        #   two atoms of comparable species
        # @raise [RuntimeError] if some of separated multi-bonds is invalid
        # @return [Array] the array of all possible intersections
        def intersec(first, second, collaps_multi_bond: false, &ver_comp_block)
          smb = collaps_multi_bond

          unless block_given?
            # because order of intersections should be contant
            @@_intersec_cache ||= {}
            key = [first, second, smb]
            return @@_intersec_cache[key] if @@_intersec_cache[key]
          end

          large_graph = Graph.new(first, collaps_multi_bond: smb)
          small_graph = Graph.new(second, collaps_multi_bond: smb)
          assoc_graph =
            AssocGraph.new(large_graph, small_graph, comparer: ver_comp_block)

          result = HanserRecursiveAlgorithm.new(assoc_graph).intersec
          @@_intersec_cache[key] = result unless block_given?
          result
        end

        # Gets first full possible intersec between two species
        # @param [Hash] first see at #intersec same argument
        # @param [Hash] second see at #intersec same argument
        # @option [Boolean] :collaps_multi_bond same as #intersec argument
        # @yeild [Graph, Graph, Concepts::Atom, Concepts::Atom] see at #intersec same
        #   argument
        # @return [Set] the set of atom pairs for two species
        def first_general_intersec(first, second, collaps_multi_bond: false, &block)
          smb = collaps_multi_bond
          intersec(first, second, collaps_multi_bond: smb, &block).first
        end
      end
    end

  end
end
