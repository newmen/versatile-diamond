module VersatileDiamond
  module Generators
    module Code

      # Provides logic for generation the find specie algorithm
      class Algorithm
        include Modules::ListsComparer
        extend Forwardable

        # Initializes algorithm by specie and essence of it
        # @param [Specie] specie for which algorithm will builded
        # @param [Essence] essence by which algorithm will builded
        def initialize(specie, essence)
          @specie, @essence = specie, essence
        end

        # Makes algorithm graph by which code of algorithm will be generated
        # @return [Hash] the grouped graph without reverse relations if them could be
        #   excepted
        def finite_graph
          anchors_to_gkeys = anchors_to_grouped_keys
          sequence.short.reduce(grouped_graph) do |acc, anchor|
            limits = anchor.relations_limits
            gkey = anchors_to_gkeys[anchor]

            if acc[gkey]
              group_again(acc, gkey).reduce(acc) do |g, (rp, nbrs)|
                raise 'Incomplete grouping in essence' unless nbrs.size == 1
                # next line .reduce for case if incomplete grouping still takes plase
                num = nbrs.reduce(0.0) { |acc, ns| acc + ns.size } / gkey.size
                raise 'Atom has to more relations' if limits[rp] < num

                could_be_cleared =
                  !anchor.lattice ||
                  limits[rp] == num ||
                  lists_are_identical?(aps_from(gkey), aps_from(nbrs.flatten), &:==)

                could_be_cleared ? without_reverse(g, gkey) : g
              end
            else
              acc
            end
          end
        end

      private

        def_delegators :@specie, :spec, :sequence
        def_delegator :@essence, :grouped_graph

        # Makes mirror from anchors to correspond keys of grouped graph
        # @return [Hash] the mirror from anchors to grouped graph keys
        def anchors_to_grouped_keys
          sorted_keys = grouped_graph.keys.sort_by(&:size)
          sorted_keys.each_with_object({}) do |key, result|
            key.each do |anchor|
              next if result[anchor]
              result[anchor] = key
            end
          end
        end

        # Collects similar relations that available by key of grouped graph
        # @param [Array] gkey the key of grouped graph
        # @return [Array] the array where each item is array that contains the
        #   following elements: first item is relation parameters, second item is
        #   array of all neighbour atoms groups available by passed key of grouped
        #   graph
        def group_again(graph, gkey)
          graph[gkey].group_by(&:last).map do |rp, group|
            [rp, group.map(&:first)]
          end
        end

        # Makes list of atom properties from passed atoms list
        # @param [Array] atoms each of which will be converted to atom property
        # @return [Array] the array of atom properties
        def aps_from(atoms)
          atoms.map { |a| Organizers::AtomProperties.new(spec, a) }
        end

        # Removes reverse relations to atoms which using in key
        # @param [Hash] graph from which reverse relations will be excepted
        # @param [Array] key of graph to which the reverse relations will be excepted
        # @return [Hash] the graph without reverse relations
        def without_reverse(graph, key)
          reject_proc = proc { |k| key.include?(k) }

          # except multi reverse relations
          other_side_keys = graph[key].map(&:first)
          without_full_others = except_relations(graph, reject_proc) do |k|
            other_side_keys.include?(k)
          end

          # except single reverse relations
          single_other_keys = other_side_keys.flatten.uniq
          except_relations(without_full_others, reject_proc) do |k|
            k.size == 1 && single_other_keys.include?(k.first)
          end
        end

        # Removes relations from passed graph by two conditions
        # @param [Proc] reject_proc the function which reject neighbours atoms
        # @yield [Array] by it condition checks that erasing should to be
        # @return [Hash] the graph without erased relations
        def except_relations(graph, reject_proc, &condition_proc)
          graph.each_with_object({}) do |(key, rels), result|
            if condition_proc[key]
              new_rels = rels.reduce([]) do |acc, (as, r)|
                new_as = as.reject(&reject_proc)
                new_as.empty? ? acc : acc << [new_as, r]
              end

              result[key] = new_rels unless new_rels.empty?
            else
              result[key] = rels
            end
          end
        end
      end

    end
  end
end
