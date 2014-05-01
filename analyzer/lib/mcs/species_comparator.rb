module VersatileDiamond
  module Mcs

    # Compares two specs by it links and get intersection of them.
    # Adapter for HanserRecursiveAlgorithm for using in concept species
    class SpeciesComparator
      class << self
        # Checks contents of the second spec in the first
        # @param [Hash] first see at #self.intersection same argument
        # @param [Hash] second see at #self.intersection same argument
        # @option [Boolean] :separated_multi_bond see at #self.intersection same
        #   argument
        # @return [Boolean] contain or not
        def contain?(first, second, **options)
          traversal = intersec(first, second, options).first
          traversal && traversal.size == second.links.size
        end

        # Gets all intersection between large links hash small links hashes
        # @param [Hash] first links of structure in which to search
        # @param [Hash] second links that search will be carried out
        # @option [Boolean] :separated_multi_bond set to true if need separated
        #   instances for double or triple bonds
        # @raise [RuntimeError] if some of separated multi-bonds is invalid
        # @return [Array] the array of all possible intersections
        def intersec(first, second, separated_multi_bond: false)
          smb = separated_multi_bond

          @@_intersec_cache ||= {}
          key = [first, second, smb]

          return @@_intersec_cache[key] if @@_intersec_cache[key]

          large_graph = Graph.new(first.links, separated_multi_bond: smb)
          small_graph = Graph.new(second.links, separated_multi_bond: smb)
          assoc_graph = AssocGraph.new(large_graph, small_graph)

          @@_intersec_cache[key] = HanserRecursiveAlgorithm.new(assoc_graph).intersec
        end

        # Gets first full possible intersec between two species
        # @param [Hash] first see at #intersec same argument
        # @param [Hash] second see at #intersec same argument
        # @return [Set] the set of atom pairs for two species
        def first_general_intersec(first, second)
          intersec(first, second, separated_multi_bond: false).first
        end

      end
    end

  end
end