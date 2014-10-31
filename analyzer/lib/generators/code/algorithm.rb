module VersatileDiamond
  module Generators
    module Code

      # Provides logic for generation the find specie algorithm
      class Algorithm
        include Modules::ListsComparer
        include AtomPropertiesUser
        extend Forwardable

        # Initializes algorithm by specie and essence of it
        # @param [Specie] specie for which algorithm will builded
        def initialize(specie)
          @specie = specie
          @_finite_graph, @_anchors_to_grouped_keys = nil
        end

        # Makes algorithm graph by which code of algorithm will be generated
        # @return [Hash] the grouped graph without reverse relations if them could be
        #   excepted
        # TODO: must be private
        def finite_graph
          @_finite_graph ||= sequence.short.reduce(grouped_graph) do |acc, anchor|
            limits = anchor.relations_limits
            gkey = anchors_to_grouped_keys[anchor]

            if acc[gkey]
              group_again(acc, gkey).reduce(acc) do |g, (rp, nbrs)|
                raise 'Incomplete grouping in essence' unless nbrs.size == 1
                # next line .reduce for case if incomplete grouping still takes plase
                num = nbrs.reduce(0.0) { |acc, ns| acc + ns.size } / gkey.size
                raise 'Atom has to more relations' if limits[rp] < num

                could_be_cleared =
                  !anchor.lattice ||
                  limits[rp] == num ||
                  lists_are_identical?(aps_from(*gkey), aps_from(*nbrs.flatten), &:==)

                could_be_cleared ? without_reverse(g, gkey) : g
              end
            else
              acc
            end
          end
        end

        # Makes directed graph for walking find algorithm builder
        # @param [Array] anchors from wich reverse relations of finite_graph will
        #   be rejected
        # @param [Hash] directed graph without loops
        # @option [Hash] :init_graph the graph which uses as initial value for
        #   internal purging graph
        # @option [Set] :visited_keys the set of visited vertices of internal purging
        #   graph
        # @return [Array] the ordered list that contains the ordered relations from
        #   finite graph
        # TODO: must be private
        def ordered_graph_from(anchors, init_graph: nil, visited_keys: Set.new)
          result = []
          directed_graph = init_graph || finite_graph
          anchors_queue = anchors.dup

          until anchors_queue.empty?
            anchor = anchors_queue.shift
            gkey = anchors_to_grouped_keys[anchor]
            next if visited_keys.include?(gkey)

            visited_keys << gkey
            rels = directed_graph[gkey]
            next unless rels

            result << [gkey, sort_rels_by_limits_of(gkey, rels)]
            next if rels.empty?

            directed_graph = without_reverse(directed_graph, gkey)
            anchors_queue += rels.flat_map(&:first)
          end

          connected_keys_from(directed_graph).each do |gkey|
            next if visited_keys.include?(gkey)
            params = { init_graph: directed_graph, visited_keys: visited_keys }
            result += ordered_graph_from(gkey, params)
          end

          unconnected_keys_from(directed_graph).each do |gkey|
            result << [gkey, []] unless visited_keys.include?(gkey)
          end

          result
        end

        # Reduces directed graph maked from passed atoms
        # @param [Object] init_value for reduce operation
        # @param [Array] atoms see at #ordered_graph_from same argument
        # @param [Proc] relations_proc do for each anchors and their neighbour atoms
        #   with using a relation parameters between them
        # @param [Proc] complex_proc do for each single anchor which no have neighbour
        #   atoms
        def reduce_directed_graph_from(init_value, atoms, relations_proc, complex_proc)
          ordered_graph_from(atoms).reduce(init_value) do |ext_acc, (anchors, rels)|
            if rels.empty?
              complex_proc[ext_acc, anchors.first]
            else
              rels.reduce(ext_acc) do |int_acc, (nbrs, relation_params)|
                relations_proc[int_acc, anchors, nbrs, relation_params]
              end
            end
          end
        end

      private

        def_delegators :@specie, :spec, :sequence, :essence
        def_delegator :essence, :grouped_graph

        # Makes mirror from anchors to correspond keys of grouped graph
        # @return [Hash] the mirror from anchors to grouped graph keys
        def anchors_to_grouped_keys
          return @_anchors_to_grouped_keys if @_anchors_to_grouped_keys

          sorted_keys = grouped_graph.keys.sort_by(&:size)
          @_anchors_to_grouped_keys =
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

        # Sorts passed relations list by relation limits of passed anchors
        # @param [Array] anchors from which relation limits will be gotten
        # @param [Array] rels the relations list of passed anchors
        # @return [Array] the sorted list of relations
        def sort_rels_by_limits_of(anchors, rels)
          rels.sort_by do |nbrs, rel_params|
            rel_ratio = nbrs.size / anchors.size
            max_limit = anchors.map { |a| a.relations_limits[rel_params] }.max
            max_limit == rel_ratio ? max_limit : 1000 + max_limit - rel_ratio
          end
        end

        # Gets the list of keys-vertices which with relations list from passed graph
        # @param [Hash] graph in which connected keys will be found
        # @return [Array] the list of connected keys-vertices
        def connected_keys_from(graph)
          graph.reject { |_, rels| rels.empty? }.map(&:first)
        end

        # Gets the list of unconnected keys-vertices from passed graph
        # @param [Hash] graph in which unconnected keys will be found
        # @return [Array] the list of unconnected keys-vertices
        def unconnected_keys_from(graph)
          keys = graph.select { |_, rels| rels.empty? }.map(&:first)
          keys.each do |k|
            raise 'Invalid unconnected key' unless k.size == 1
          end
          keys
        end
      end

    end
  end
end
