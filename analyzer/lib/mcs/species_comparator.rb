module VersatileDiamond
  module Mcs

    # Compares two specs by it links and get intersection of them.
    # Adapter for HanserRecursiveAlgorithm for using in concept species
    class SpeciesComparator
      class << self
        # Checks contents of the second spec in the first
        # @param [ISpec] first see at #intersec same argument
        # @param [ISpec] second see at #intersec same argument
        # @param [Hash] kwargs will be passed to intersection find method
        # @return [Boolean] contain or not
        def contain?(first, second, **kwargs)
          return true if first.equal?(second)
          traversal = intersec(first, second, kwargs).first
          traversal && traversal.size == second.links.size
        end

        # Gets all intersection between large links hash small links hashes
        # @param [ISpec] first spec with links in which to search
        # @param [ISpec] second spec with links that search will be carried out
        # @param [Hash] kwargs will be used under Graph instance creation
        # @yeild [Graph, Graph, Concepts::Atom, Concepts::Atom] if presented compares
        #   two atoms of comparable species
        # @raise [RuntimeError] if some of separated multi-bonds is invalid
        # @return [Array] the array of all possible intersections
        def intersec(first, second, **kwargs, &block)
          unless block_given?
            # because order of intersections should be constant
            @@_intersec_cache ||= {}
            key = [first, second, kwargs]
            return @@_intersec_cache[key] if @@_intersec_cache[key]
          end

          large_graph = Graph.new(first, **kwargs)
          small_graph = Graph.new(second, **kwargs)
          assoc_graph = AssocGraph.new(large_graph, small_graph, comparer: block)

          result = HanserRecursiveAlgorithm.new(assoc_graph).intersec
          @@_intersec_cache[key] = result unless block_given?
          result
        end

        # Makes the mirror of atoms of first spec to atoms of second spec
        # @param [ISpec] first see at #intersec same argument
        # @param [ISpec] second see at #intersec same argument
        # @yeild [Graph, Graph, Concepts::Atom, Concepts::Atom] see at #intersec same
        #   argument
        # @return [Hash] the mirror of atoms of first spec to atoms of second spec
        def make_mirror(first, second, &block)
          kwargs = { collaps_multi_bond: true }
          insec = first_general_intersec(first, second, **kwargs, &block)
          insec && Hash[insec.to_a]
        end

      private

        # Gets first full possible intersec between two species
        # @param [ISpec] first see at #intersec same argument
        # @param [ISpec] second see at #intersec same argument
        # @param [Hash] kwargs will be passed to intersection find method
        # @yeild [Graph, Graph, Concepts::Atom, Concepts::Atom] see at #intersec same
        #   argument
        # @return [Set] the set of atom pairs for two species
        def first_general_intersec(first, second, **kwargs, &block)
          all_isecs = intersec(first, second, **kwargs, &block)
          max_isecs = select_maximals(all_isecs)
          resort_intersecs(max_isecs, first, second).first
        end

        # Selects the intersects which are maximal by accurate comparing atoms of them
        # @param [Array] the list of intersections by accurate same atoms
        def select_maximals(intersecs)
          as_nums = intersecs.map do |isec|
            isec.reduce(0) do |acc, (v, w)|
              a, b = v.is_a?(Array) && w.is_a?(Array) ? [v, w].map(&:last) : [v, w]
              acc + (a.accurate_same?(b) ? 1 : 0)
            end
          end

          max_num = as_nums.max
          as_nums.zip(intersecs).select { |n, _| n == max_num }.map(&:last)
        end

        # @param [ISpec] spec
        # @param [Concepts::Atom...] atom
        # @return [Symbol]
        def keyname_from(spec, atom)
          spec.keyname(atom)
        end

        # @param [Array] intersecs which will be resorted
        # @return [Array] the reordered list of passed intersections
        def resort_intersecs(intersecs, first, second)
          fs, ss = first.links.size, second.links.size
          intersecs.sort_by do |isec|
            isec.map do |v, w|
              kn_pair =
                if v.is_a?(Array) && w.is_a?(Array)
                  [v, w].map { |pair| keyname_from(*pair) }
                else
                  [keyname_from(first, v), keyname_from(second, w)]
                end

              fs > ss ? kn_pair.rotate : kn_pair
            end
          end
        end
      end
    end

  end
end
