module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides methods for make grouped nodes graph
        # @abstract
        class BaseGroupedNodes
          include SpeciesUser

          # Initizalize cleaner by specie class code generator
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            @generator = generator
            @_final_graph = nil
          end

          # Gets the nodes of small links graph which are grouped by available
          # neighbours which are available through flatten relations that belongs to
          # some crystal face
          #
          # @return [Array] the array of arrays where each group contain similar
          #   related nodes
          # TODO: must be private
          def flatten_face_grouped_nodes
            groups = small_links_graph.keys.group_by do |node|
              Set.new(flatten_neighbours_for(node) + [node])
            end
            groups.values
          end

          # Provides undirected graph of algorithm without bonds duplications. Nodes of
          # big_links_graph are grouped there by flatten relations between nodes
          # of small_links_graph graph.
          #
          # @return [Hash] the hash of sparse graph where keys are arrays of nodes
          #   which have similar relations with neighbour nodes and values are wrapped
          #   to arrays other side "vertex" and relation to it vertex
          def final_graph
            return @_final_graph if @_final_graph

            result = {}
            store_result = proc do |nodes, nbrs_with_rel_param|
              result[nodes] ||= []
              result[nodes] << nbrs_with_rel_param if nbrs_with_rel_param
            end

            flatten_groups, non_flatten_groups = split_grouped_nodes

            flatten_groups.each do |group|
              combine_accurate_relations(group, &store_result)
            end

            non_flatten_groups.each do |group|
              combine_similar_relations(group, &store_result)
            end

            @_final_graph = result
          end

        private

          attr_reader :generator

          # Makes the graph of nodes from passed graph
          # @param [Hash] links the original graph
          # @return [Hash] the graph with nodes
          def transform_links(links)
            links.each_with_object({}) do |(vertex, rels), result|
              result[get_node(vertex)] = rels.map do |v, relation|
                [get_node(v), relation]
              end
            end
          end

          # Gets nodes that used in small links graph
          # @return [Array] the nodes which using in small links graph
          def main_keys
            small_links_graph.keys
          end

          # Gets all flatten relations of passed node
          # @param [Array] node the pair of specie and atom isntances for which
          #   the flatten relations will be gotten
          # @return [Array] the array of relations where each relation is array of two
          #   items, where first item is neighbour atom and second item is relation
          #   instance
          def flatten_relations_of(node)
            flatten_rels = big_links_graph[node].select do |n, r|
              flatten_relation?(n, r) && main_keys.include?(n)
            end
          end

          # Gets all non flatten relations of passed node
          # @param [Array] node the pair of specie and atom isntances for which
          #   the non flatten relations will be gotten
          # @return [Array] the array of relations where each relation is array of two
          #   items, where first item is neighbour atom and second item is relation
          #   instance
          def non_flatten_relations_of(node)
            small_links_graph[node].reject { |n, r| flatten_relation?(n, r) }
          end

          # Gets all flatten neighbours of passed node. Moreover, if an node has a few
          # ways for getting neighbors in flat face, then selects the most optimal.
          #
          # @param [Array] node the pair of specie and atom isntances for which
          #   the neighbour nodes which avail from passed
          # @return [Array] the array of neighbour atoms which available through
          #   flatten relation
          def flatten_neighbours_for(node)
            flatten_nbrs = flatten_relations_of(node).map(&:first)
            if flatten_nbrs.size > 1
              flatten_nbrs.reject { |n| alive_relation?(node, n) }
            else
              flatten_nbrs
            end
          end

          # Checks that passed relation is flatten on crystal lattice
          # @return [Boolean] is flatten relation or not
          def flatten_relation?(node, relation)
            if node.lattice
              relation.relation? && node.lattice.instance.flatten?(relation)
            else
              false
            end
          end

          # Checks that small links graph has relation between passed nodes
          # @param [Node] from is the first node
          # @param [Node] to is the second node
          # @return [Boolean] has relation or not
          def alive_relation?(from, to)
            has_relation_in?(small_links_graph, from, to)
          end

          # Checks that clean specie links graph has relation between passed nodes
          # @param [Node] from is the first node
          # @param [Node] to is the second node
          # @return [Boolean] has relation or not
          def has_relation?(from, to)
            has_relation_in?(big_links_graph, from, to)
          end

          # Checks that relation is present between passed nodes in also passed links
          # @param [Hash] links where relation will be found or not
          # @param [Node] from is the first node
          # @param [Node] to is the second node
          # @return [Boolean] has relation or not
          def has_relation_in?(links, from, to)
            links[from].any? { |n, _| n == to }
          end

          # Checks that node has flatten relation
          # @param [Node] node which relations will be checked
          # @return [Boolean] node has flatten relation or not
          def has_flatten_relation?(node)
            !flatten_relations_of(node).empty?
          end

          # Checks that node has non flatten relation
          # @param [Array] node which relations will be checked
          # @return [Boolean] node has non flatten relation or not
          def has_non_flatten_relation?(node)
            !non_flatten_relations_of(node).empty?
          end

          # Verifies that all flatten relations, which passed node have relations only
          # with nodes from the passed group
          #
          # @param [Array] group of similar nodes
          # @param [Array] node which relations will be checked
          # @return [Boolean] are flatten relations used only by group nodes or not
          def only_flatten_relations_in?(group, node)
            rels = small_links_graph[node].select { |n, r| flatten_relation?(n, r) }
            rels.all? { |n, _| group.include?(n) }
          end

          # Separates the grouped nodes into two categories: nodes with flatten
          # relations and nodes with non flatten relations
          #
          # @return [Array] the array with two items where each item is array. The
          #   first item is groups of nodes with flatten relations and the second item
          #   is groups of nodes with non flatten relations
          def split_grouped_nodes
            flatten_groups = flatten_face_grouped_nodes.select do |group|
              group.any? do |node|
                has_flatten_relation?(node) && !only_flatten_relations_in?(group, node)
              end
            end

            non_flatten_groups = flatten_face_grouped_nodes.select do |group|
              group.any? do |node|
                dept_only_from_group = only_flatten_relations_in?(group, node)
                dept_only_from_group || small_links_graph[node].empty? ||
                  (!dept_only_from_group && has_non_flatten_relation?(node))
              end
            end

            [flatten_groups, non_flatten_groups]
          end

          # Gets all subsets of passed set
          # @param [Array] set for which all subsets will be gotten
          # @return [Array] the array with all subsets of passed set grouped by
          #   number of elements in subset
          def all_subsets_of(set)
            2.upto(set.size).map { |n| set.combination(n).to_a }
          end

          # Recursive regroups flatten sequence if item is array
          # @param [Array] sequence which will be regrouped if need
          # @param [Object] item by which dimension the original sequence will be
          #   regrouped
          # @return [Array] the sequence of grouped elements
          def regroup(sequence, item)
            if item.is_a?(Array)
              regroup(sequence, item.first).each_slice(item.size)
            else
              sequence
            end
          end

          # Products passed lists and combinates them items
          # @param [Array] lists which will be sliced and combinated; all lists should
          #   have same dimensions
          # @return [Array] the list of all possible combinations of items of passed
          #   lists
          # @example
          #   [[1, 2, 3], [8, 9], [0]] =>
          #     [[1, 8, 0], [1, 9, 0], [2, 8, 0], [2, 9, 0], [3, 8, 0], [3, 9, 0]]
          def slices_combination(lists)
            head, *tail = lists
            products = tail.reduce(head) { |acc, list| acc.product(list) }
            sequence = products.flatten
            sequence = regroup(sequence, head.first)
            sequence.each_slice(lists.size)
          end

          # Checks that each consecutive pair of passed list correspond to passed
          # predicate
          #
          # @param [Array] list which will be checked
          # @yield [Object, Object] the predicate function
          # @return [Boolean] are all consecutive pairs correpond to predicate or not
          def all_cons_pairs?(list, &block)
            # splits each internal array to two independent elements
            list.each_cons(2).all? { |a, b| block[a, b] }
          end

          # Accumulates node with their most optimal neighbours
          # @param [Array] nodes which environment in flatten crystal face will be
          #   checked
          # @return [Array] the array with two items where the first item is array of
          #   nodes from which has similar relations to neighbour nodes which placed as
          #   second item of array
          def accurate_node_groups_from(nodes)
            small_rels = nodes.map { |node| small_links_graph[node] }

            accurate_groups = []
            all_subsets_of(nodes.zip(small_rels)).each do |subsets|
              found_on_subset = false
              subsets.each do |subset|
                current_nodes, srels = subset.transpose

                nbrs_with_rels_groups =
                  slices_combination(srels).select do |comb_rels|
                    nbrs, relations = comb_rels.transpose
                    all_cons_pairs?(relations) { |a, b| a.it?(b.params) } &&
                      all_cons_pairs?(nbrs, &method(:has_relation?))
                  end

                next if nbrs_with_rels_groups.empty?
                found_on_subset = true

                nbrs_with_rels_groups.each do |group|
                  neighbours = group.map(&:first)
                  accurate_groups << [current_nodes, neighbours]
                end
              end
              break if found_on_subset
            end

            accurate_groups
          end

          # Iterates accurate groups of nodes which avail by passed group
          # @return [Array] group the list of nodes which accurate neighbours will be
          #   iterated
          # @yeild [Array, (Array, Hash)] do for nodes and them neighbours
          def combine_accurate_relations(group, &block)
            accurate_node_groups_from(group).each do |nodes, nbrs|
              relation = relation_between(nodes.first, nbrs.first)
              block[nodes, [nbrs, relation.params]]
            end
          end

          # Combines similar relations which could be available for each atom from the
          # passed group
          #
          # @param [Array] group of nodes each of which could combine similar relations
          #   and neighbour nodes
          # @yield [Array, Hash] iterates each case after getting relations for each
          #   atom from group; the first argument of block procedure is array of nodes,
          #   which was combined when method do, but every time it array contain just
          #   one item which is iterating atom; the second argument of block procedure
          #   is relation parameters for neighbour nodes array
          def combine_similar_relations(group, &block)
            group.each do |node|
              key = [node]
              rels = small_links_graph[node]

              if rels.empty?
                block[key, nil]
              else
                selected_rels =
                  if only_flatten_relations_in?(group, node)
                    rels
                  else
                    non_flatten_relations_of(node)
                  end

                similar_rels_groups = selected_rels.group_by do |n, r|
                  [n.properties, r.params]
                end

                similar_rels_groups.values.each do |similar_rels|
                  nbrs, relations = similar_rels.transpose
                  block[key, [nbrs, relations.first.params]]
                end
              end
            end
          end
        end

      end
    end
  end
end
