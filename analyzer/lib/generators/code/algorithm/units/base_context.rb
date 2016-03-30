module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of find algoritnm builder
        # @abstract
        class BaseContext
          include Modules::ListsComparer

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Hash] nodes_graph
          # @param [Array] ordered_backbone
          def initialize(dict, nodes_graph, ordered_backbone)
            @dict = dict
            @nodes_graph = nodes_graph
            @backbone_graph = Hash[ordered_backbone]

            @_key_nodes_lists, @_side_nodes_lists = nil
            @_uniq_nodes = nil
          end

          # @param [Array] atoms
          # @return [Array]
          def atoms_nodes(atoms)
            uniq_nodes.select { |node| atoms.include?(node.atom) }
          end

          # @param [Array] species
          # @return [Array]
          def species_nodes(species)
            uniq_nodes.select { |node| species.include?(node.uniq_specie) }
          end

          # @param [Array] species
          # @return [Array]
          def reachable_nodes_with(species)
            fileter_nodes_with(:reject, species)
          end

          # @param [Array] species
          # @return [Array]
          # @deprecated
          def reached_nodes_with(species)
            fileter_nodes_with(:select, species)
          end

          # Gets nodes which belongs to passed nodes but have existed relations from
          # nodes which are not same as passed
          #
          # @param [Array] nodes
          # @return [Array]
          def existed_relations_to(nodes)
            filter_relations_to(nodes, &:exist?)
          end

          # Gets nodes which belongs to passed nodes but have not existed relations
          # from nodes which are not same as passed
          #
          # @param [Array] nodes
          # @return [Array]
          def not_existed_relations_to(nodes)
            filter_relations_to(nodes) { |rel| !rel.exist? }
          end

          # @param [Nodes::BaseNode] a
          # @param [Nodes::BaseNode] b
          # @return [Concepts::Bond]
          def relation_between(a, b)
            to_b = bone_relations_of([a]).first.find { |node, _| node == b }
            to_b && to_b.last
          end

          # @param [Array] species
          # @return [Array]
          def symmetric_close_nodes(species)
            undefined_related_nodes(species).uniq(&:to_set)
          end

          # @param [Array] nodes
          # @return [Boolean]
          def symmetric_relations?(nodes)
            if nodes.empty?
              raise ArgumentError, 'Empty nodes list passed'
            elsif !nodes.one?
              rels_lists = bone_relations_of(nodes)
              !rels_lists.any?(&:empty?) && same_relations?(rels_lists) &&
                same_side_props?(rels_lists) && same_side_species?(rels_lists)
            else
              false
            end
          end

          # @param [Array] nodes
          # @return [Boolean]
          def related_from_other_defined?(nodes)
            species = nodes.map(&:uniq_specie)
            backbone_graph.any? do |key, rels|
              atom_defined_and_not_in?(key, species) &&
                rels.any? do |ns, _|
                  ns.any? { |node| nodes.include?(node) }
                end
            end
          end

        private

          attr_reader :nodes_graph, :backbone_graph

          # @return [Array]
          def uniq_nodes
            @_uniq_nodes ||= (backbone_graph.keys + side_nodes_lists).flatten.uniq
          end

          # @return [Array]
          def key_nodes_lists
            @_key_nodes_lists ||= backbone_graph.keys
          end

          # @return [Array]
          def side_nodes_lists
            @_side_nodes_lists ||=
              backbone_graph.values.flat_map { |rels| rels.map(&:first) }
          end

          # @param [Array] nodes
          # @return [Array]
          def bone_relations_of(nodes)
            nodes.map do |node|
              nodes_graph[node].select { |n, _| major_relation?(node, n) }
            end
          end

          # @param [Symbol] method_name
          # @param [Array] uniq_species
          def fileter_nodes_with(method_name, uniq_species)
            species_nodes(uniq_species).send(method_name) do |node|
              @dict.var_of(node.atom)
            end
          end

          # @param [Array] nodes
          # @yield [Concepts::Bond] filter relation to selected nodes
          # @return [Array] nodes with filtered relations
          def filter_relations_to(nodes, &block)
            species = nodes.map(&:uniq_specie)
            key_nodes_lists.each_with_object([]) do |key, acc|
              if atom_defined_and_not_in?(key, species)
                each_defined_relation(key) do |node, rel|
                  acc << node if nodes.include?(node) && block[rel]
                end
              end
            end
          end

          # @param [Array] nodes
          # @yield [Nodes::BaseNode, Concepts::Bond] iterates each relation of nodes
          def each_defined_relation(nodes, &block)
            rels = bone_relations_of(nodes).reduce(:+)
            backbone_graph[nodes].each do |ns, _|
              rels.each do |n, r|
                block[n, r] if @dict.var_of(n.atom) && ns.include?(n)
              end
            end
          end

          # @param [Array] uniq_species
          # @return [Array] lists of related nodes with undefined atoms
          def undefined_related_nodes(uniq_species)
            nodes_lists = undefined_atoms_nodes(key_nodes_lists, uniq_species)
            nodes_lists.select(&method(:undefined_symmetric_atoms?))
          end

          # @param [Array] nodes_lists
          # @param [Array] uniq_species
          # @return [Array]
          def undefined_atoms_nodes(nodes_lists, uniq_species)
            nodes_lists.select do |nodes|
              nodes.all? do |node|
                !@dict.var_of(node.atom) && uniq_species.include?(node.uniq_specie)
              end
            end
          end

          # @param [Array] nodes
          # @param [Array] uniq_species
          # @return [Boolean]
          def atom_defined_and_not_in?(nodes, uniq_species)
            nodes.any? do |node|
              @dict.var_of(node.atom) && !uniq_species.include?(node.uniq_specie)
            end
          end

          # @param [Array] nodes
          # @return [Array]
          def undefined_symmetric_atoms?(nodes)
            atoms_lists = nodes.map(&:symmetric_atoms)
            !atoms_lists.any?(&:empty?) &&
              atoms_lists.all? { |atoms| !atoms.any?(&@dict.public_method(:var_of)) }
          end

          # @param [Array] rels_lists
          # @return [Boolean]
          def same_relations?(rels_lists)
            same_rels_when?(rels_lists) { |rels| rels.map(&:last).select(&:exist?) }
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_side_props?(rels_lists)
            same_rels_when?(rels_lists) { |rels| rels.map(&:first).map(&:properties) }
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_side_species?(rels_lists)
            same_rels_when?(rels_lists) do |rels|
              rels.map(&:first).map(&:uniq_specie).map(&:original)
            end
          end

          # @return [Array] rels_lists
          # @yield [Array] transforms the relations list
          # @return [Boolean]
          def same_rels_when?(rels_lists, &block)
            lists_are_identical?(*rels_lists.map(&block), &:==)
          end

          # @param [Nodes::BaseNode] a
          # @param [Nodes::BaseNode] b
          # @return [Boolean]
          def symmetric_relation_between?(a, b)
            ab_relation = relation_between(a, b)
            if ab_relation
              ba_relation = b.lattice.opposite_relation(a.lattice, ab_relation)
              ab_relation == ba_relation
            else
              false
            end
          end

          # @param [Nodes::BaseNode] a
          # @param [Nodes::BaseNode] b
          # @return [Boolean]
          def major_relation?(a, b)
            backbone_graph.any? do |nodes, rels|
              nodes.include?(a) && rels.any? { |ns, _| ns.include?(b) }
            end
          end
        end

      end
    end
  end
end
