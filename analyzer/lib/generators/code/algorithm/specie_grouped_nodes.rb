module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for clean dependent specie and get essence of specie graph
        class SpecieGroupedNodes
          include SpeciesUser
          extend Forwardable

          # Initizalize cleaner by specie class code generator
          # @param [Specie] specie from which pure essence will be gotten
          def initialize(generator, specie)
            @generator = generator
            @specie = specie

            @atoms_to_nodes = {}
            @parents_to_uniques = {}

            @_original_links_graph, @_cut_links_graph, @_final_graph = nil
          end

          # Gets the nodes of cut links graph which are grouped by available neighbours
          # which are available through flatten relations that belongs to some crystal
          # face
          #
          # @return [Array] the array of arrays where each group contain similar
          #   related nodes
          # TODO: must be private
          def face_grouped_nodes
            groups = cut_links_graph.keys.group_by do |node|
              Set.new(flatten_neighbours_for(node) + [node])
            end
            groups.values
          end

          # Provides undirected graph of algorithm without bonds duplications. Nodes of
          # original_links_graph are grouped there by flatten relations between nodes
          # of cut_links_graph graph.
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
          def_delegator :@specie, :spec

          def original_links_graph
            @_original_links_graph ||= transform_links(spec.clean_links)
          end

          def cut_links_graph
            @_cut_links_graph ||= transform_links(@specie.essence.cut_links)
          end

          def transform_links(links)
            links.each_with_object({}) do |(atom, rels), result|
              result[get_node(atom)] = rels.map do |a, relation|
                [get_node(a), relation]
              end
            end
          end

          def parent_specie(atom)
            parents = spec.parents_of(atom)
            if parents.empty?
              NoneSpecie.new(@specie)
            elsif parents.size == 1
              get_unique_specie(parents.first)
            else
              SpeciesScope.new(parents.map(&method(:get_unique_specie)))
            end
          end

          def get_node(atom)
            @atoms_to_nodes[atom] ||= Node.new(@specie, parent_specie(atom), atom)
          end

          def get_unique_specie(parent)
            @parents_to_uniques[parent] ||= UniqueSpecie.new(specie_class(parent))
          end

          # Gets atoms that used in cut links graph
          # @return [Array] the atoms which using in cut links graph
          def main_keys
            cut_links_graph.keys
          end

          def relation_between(*nodes)
            atoms = nodes.map(&:atom)
            spec.relation_between(*atoms)
          end

          # Gets all flatten relations of passed atom
          # @param [Array] node the pair of specie and atom isntances for which
          #   the flatten relations will be gotten
          # @return [Array] the array of relations where each relation is array of two
          #   items, where first item is neighbour atom and second item is relation
          #   instance
          def flatten_relations_of(node)
            flatten_rels = original_links_graph[node].select do |n, r|
              flatten_relation?(n, r) && main_keys.include?(n)
            end
          end

          # Gets all non flatten relations of passed atom
          # @param [Array] node the pair of specie and atom isntances for which
          #   the non flatten relations will be gotten
          # @return [Array] the array of relations where each relation is array of two
          #   items, where first item is neighbour atom and second item is relation
          #   instance
          def non_flatten_relations_of(node)
            cut_links_graph[node].reject { |n, r| flatten_relation?(n, r) }
          end

          # Gets all flatten neighbours of passed atom. Moreover, if an atom has a few
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

          # Checks that passed relation is flatten in crystal lattice when placed atom
          # @return [Boolean] is flatten relation or not
          def flatten_relation?(node, relation)
            lattice = node.atom.lattice
            if lattice
              relation.relation? && lattice.instance.flatten?(relation)
            else
              false
            end
          end

          # Checks that cut links graph has relation between passed atoms
          # @param [Array] from is the first node
          # @param [Array] to is the second node
          # @return [Boolean] has relation or not
          def alive_relation?(from, to)
            has_relation_in?(cut_links_graph, from, to)
          end

          # Checks that clean specie links graph has relation between passed atoms
          # @param [Array] from is the first node
          # @param [Array] to is the second node
          # @return [Boolean] has relation or not
          def has_relation?(from, to)
            has_relation_in?(original_links_graph, from, to)
          end

          # Checks that relation is present between passed atoms in also passed links
          # @param [Hash] links where relation will be found or not
          # @param [Array] from is the first node
          # @param [Array] to is the second node
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

          # Verifies that all flatten relations which passed atom have is link it only
          # with nodes from the passed group
          #
          # @param [Array] group of similar nodes
          # @param [Array] node which relations will be checked
          # @return [Boolean] are flatten relations used only by group nodes or not
          def only_flatten_relations_in?(group, node)
            rels = cut_links_graph[node].select { |n, r| flatten_relation?(n, r) }
            rels.all? { |n, _| group.include?(n) }
          end

          # Separates the grouped atoms into two categories: atoms with flatten relations
          # and atoms with non flatten relations
          #
          # @return [Array] the array with two items where each item is array. The
          #   first item is groups of atoms with flatten relations and the second item
          #   is groups of atoms with non flatten relations
          def split_grouped_nodes
            flatten_groups = face_grouped_nodes.select do |group|
              group.any? do |node|
                has_flatten_relation?(node) && !only_flatten_relations_in?(group, node)
              end
            end

            non_flatten_groups = face_grouped_nodes.select do |group|
              group.any? do |node|
                dept_only_from_group = only_flatten_relations_in?(group, node)
                dept_only_from_group || cut_links_graph[node].empty? ||
                  (!dept_only_from_group && has_non_flatten_relation?(node))
              end
            end

            [flatten_groups, non_flatten_groups]
          end

          # Accumulates node with their most optimal neighbours
          # @param [Array] nodes which environment in flatten crystal face will be
          #   checked
          # @return [Array] the array with two items where the first item is array of
          #   nodes from which has similar relations to neighbour nodes which placed as
          #   second item of array
          def accurate_node_groups_from(nodes)
            cut_rels = nodes.map { |node| cut_links_graph[node] }
            neighbours = cut_rels.map { |rels| rels.map(&:first) }

            accurate_groups_hash = {}
            nodes.zip(neighbours).each do |node, nbrs|
              (neighbours - [nbrs]).each do |other_nbrs|
                other_nbrs.each do |other_nbr|
                  nbrs.each do |nbr|
                    # if relation presented then it in any time is flatten, because
                    # value which passed to current method is gotten from flatten anchors
                    # group
                    next unless has_relation?(nbr, other_nbr)
                    key = Set[nbr, other_nbr]
                    accurate_groups_hash[key] ||= []
                    accurate_groups_hash[key] << [node, nbr]
                  end
                end
              end
            end

            accurate_groups_hash.values.map(&:transpose)
          end

          def combine_accurate_relations(group, &block)
            accurate_node_groups_from(group).each do |nodes, nbrs|
              relation = relation_between(nodes.first, nbrs.first)
              block[nodes, [nbrs, relation.params]]
            end
          end

          # Combines similar relations which could be available for each atom from the
          # passed group
          #
          # @param [Array] group of atoms each of which could combine similar relations
          #   and neighbour atoms
          # @yield [Array, Hash] iterates each case after getting relations for each
          #   atom from group; the first argument of block procedure is array of atoms,
          #   which was combined when method do, but every time it array contain just
          #   one item which is iterating atom; the second argument of block procedure
          #   is relation parameters for neighbour atoms array
          def combine_similar_relations(group, &block)
            group.each do |node|
              key = [node]
              rels = cut_links_graph[node]

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
