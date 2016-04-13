module VersatileDiamond
  using Patches::RichArray

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

          # @return [Array]
          def bone_nodes
            @_uniq_nodes ||= splitten_nodes.flatten.uniq
          end

          # @param [Array] atoms
          # @return [Array]
          def atoms_nodes(atoms)
            bone_nodes.select { |node| atoms.include?(node.atom) }
          end

          # @param [Array] species
          # @return [Array]
          def species_nodes(species)
            bone_nodes.select { |node| species.include?(node.uniq_specie) }
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
          # @return [Array] nodes to which related the passed
          def existed_relations_to(nodes)
            filter_relations_to(nodes, &:exist?)
          end

          # Gets nodes which belongs to passed nodes but have not existed relations
          # from nodes which are not same as passed
          #
          # @param [Array] nodes
          # @return [Array] nodes to which related the passed
          def not_existed_relations_to(nodes)
            filter_relations_to(nodes) { |rel| !rel.exist? }
          end

          # @param [Array] nodes
          # @return [Array]
          def private_relations_with(nodes)
            unified_nodes = unify_by_atom(nodes)
            existed_relations_with(unified_nodes).flat_map do |node, rels|
              sames = rels.groups { |_, r| r.params }.map { |g| g.map(&:first) }
              manies = sames.map(&method(:unify_by_atom)).reject(&:one?)
              majors = manies.select { |ns| bone_with?(node, ns) }
              defined = majors.select { |ns| ns.all?(&method(:defined?)) }
              sides = defined.select { |ns| ns.any?(&method(:bone?)) }
              likes = sides.select(&method(:similar_properties?))
              likes.flat_map { |ns| ns.combination(2).to_a }
            end
          end

          # @param [Nodes::BaseNode] a
          # @param [Nodes::BaseNode] b
          # @return [Concepts::Bond]
          def relation_between(a, b)
            to_b = relations_of([a]).first.find { |node, _| node == b }
            to_b && to_b.last
          end

          # @param [Array] species
          # @return [Array]
          def symmetric_close_nodes(species)
            symmetric_related_nodes(species).uniq(&:to_set)
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
            species = nodes.map(&:uniq_specie).uniq
            backbone_graph.any? do |key, rels|
              atom_defined_and_in?(key, species) &&
                rels.any? do |ns, rp|
                  flatten_relations_of(ns).any? { |n, _| nodes.include?(n) }
                end
            end
          end

        private

          attr_reader :dict, :nodes_graph, :backbone_graph

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def bone?(node)
            bone_nodes.include?(node)
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def defined?(node)
            dict.var_of(node.atom) || dict.var_of(node.uniq_specie)
          end

          # @return [Array]
          def splitten_nodes
            key_nodes_lists + side_nodes_lists
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
          def relations_of(nodes)
            nodes.map(&nodes_graph.public_method(:[]))
          end

          # @param [Array] nodes
          # @return [Array]
          def bone_relations_of(nodes)
            nodes.zip(relations_of(nodes)).map do |node, rels|
              rels.select { |n, _| bone_relation?(node, n) }
            end
          end

          # Gets all existed relations over full big graph of context
          # @param [Array] nodes
          # @return [Array]
          def existed_relations_with(nodes)
            nodes.map do |node|
              [node, nodes_graph[node].select { |_, r| r.exist? }]
            end
          end

          # Gets nodes unified by atom, but if there are nodes with similar atom then
          # the node with defined uniq specie will be selected from
          #
          # @param [Array] nodes
          # @return [Array]
          def unify_by_atom(nodes)
            groups = nodes.groups(&:atom)
            singulars = groups.select(&:one?)
            (singulars.empty? ? [] : singulars.reduce(:+)) +
              groups.reject(&:one?).map do |ns|
                defined = ns.select { |node| dict.var_of(node.uniq_specie) }
                defined.empty? ? ns.first : defined.first
              end
          end

          # @param [Symbol] method_name
          # @param [Array] uniq_species
          def fileter_nodes_with(method_name, uniq_species)
            species_nodes(uniq_species).public_send(method_name) do |node|
              dict.var_of(node.atom)
            end
          end

          # @param [Array] nodes
          # @yield [Concepts::Bond] filter relation to selected nodes
          # @return [Array] nodes with filtered relations
          def filter_relations_to(nodes, &block)
            species = nodes.map(&:uniq_specie).uniq
            rels_to_nodes = key_nodes_lists.each_with_object([]) do |key, acc|
              if atom_defined_and_not_in?(key, species)
                each_bone_defined_relation(key) do |node, rel|
                  acc << node if nodes.include?(node) && block[rel]
                end
              end
            end
            rels_to_nodes.map(&:first).uniq
          end

          # @param [Array] nodes
          # @yield [Nodes::BaseNode, Concepts::Bond] iterates each relation of nodes
          def each_bone_defined_relation(nodes, &block)
            bone_relations_of(nodes).reduce(:+).each do |n, r|
              block[n, r] if @dict.var_of(n.atom)
            end
          end

          # @param [Array] uniq_species
          # @return [Array] lists of related nodes with undefined atoms
          def symmetric_related_nodes(uniq_species)
            nodes_lists = atoms_nodes_in(splitten_nodes, uniq_species)
            nodes_lists.select(&method(:with_symmetric_atoms?))
          end

          # @param [Array] nodes_lists
          # @param [Array] uniq_species
          # @return [Array]
          def atoms_nodes_in(nodes_lists, uniq_species)
            nodes_lists.each_with_object([]) do |nodes, acc|
              ns = nodes.select { |n| uniq_species.include?(n.uniq_specie) }
              acc << ns unless ns.empty?
            end
          end

          # @param [Array] nodes
          # @param [Array] uniq_species
          # @return [Boolean]
          # @deprecated
          def atom_defined_and_not_in?(nodes, uniq_species)
            any_defined_atom?(nodes) { |n| !uniq_species.include?(n.uniq_specie) }
          end

          # @param [Array] nodes
          # @param [Array] uniq_species
          # @return [Boolean]
          def atom_defined_and_in?(nodes, uniq_species)
            any_defined_atom?(nodes) { |n| uniq_species.include?(n.uniq_specie) }
          end

          # @param [Array] nodes
          # @yield [Nodes::BaseNode] additional check
          # @return [Boolean]
          def any_defined_atom?(nodes, &block)
            nodes.any? { |node| dict.var_of(node.atom) && block[node] }
          end

          # @param [Array] nodes
          # @return [Array]
          def with_symmetric_atoms?(nodes)
            !nodes.map(&:symmetric_atoms).any?(&:empty?)
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
          def bone_relation?(a, b)
            backbone_graph.any? do |nodes, rels|
              nodes.include?(a) && rels.any? { |ns, _| ns.include?(b) }
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Array] nodes
          # @return [Boolean]
          def bone_with?(node, nodes)
            nodes.any? { |n| bone_relation?(node, n) } &&
              !two_units_relation?(node, nodes)
          end

          # @param [Nodes::BaseNode] node
          # @return [Array] nodes
          # @return [Boolean]
          def two_units_relation?(node, nodes)
            rels = backbone_graph[[node]]
            rels && rels.any? do |ns, _|
              lists_are_identical?(nodes, ns, &:==)
            end
          end

          # @return [Array] nodes
          # @return [Boolean]
          def similar_properties?(nodes)
            nodes.each_cons(2).all? do |a, b|
              a.atom != b.atom && a.properties.like?(b.properties)
            end
          end
        end

      end
    end
  end
end
