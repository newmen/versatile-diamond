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
            bone_nodes.select { |node| atom_in?(node, atoms) }
          end

          # @param [Array] species
          # @return [Array]
          def species_nodes(species)
            bone_nodes.select { |node| specie_in?(node, species) }
          end

          # @param [Array] species
          # @return [Array]
          def similar_atoms_nodes_pairs(species)
            species.combination(2).flat_map do |species_pair|
              if species_pair.map(&:original).uniq.one?
                []
              else
                atoms_pairs = atoms_pairs_for(*species_pair)
                nodes_pairs = nodes_pairs_for(species_pair, atoms_pairs)
                nodes_pairs.select do |ns|
                  defined_bones = ns.map { |n| bone?(n) && atom_defined?(n) }
                  defined_bones.any? && !defined_bones.all?
                end
              end
            end
          end

          # @param [Array] species
          # @return [Array]
          def reachable_bone_nodes_with(species)
            species_nodes(species).reject(&method(:atom_defined?))
          end

          # @param [Array] target_nodes
          # @return [Array]
          def reachable_bone_nodes_after(target_nodes)
            cutten_backbone = cut_backbone_from(target_nodes)
            species_nodes(target_nodes.map(&:uniq_specie)).select do |node|
              cutten_backbone.any? { |key_rels| slice(*key_rels).include?(node) }
            end
          end

          # Gets nodes which belongs to passed nodes but have existed relations from
          # nodes which are not same as passed
          #
          # @param [Array] nodes
          # @return [Array] nodes to which the another nodes are related
          def existed_relations_to(nodes)
            filter_relations_to(nodes, &:exist?)
          end

          # Gets nodes which belongs to passed nodes but have not existed relations
          # from nodes which are not same as passed
          #
          # @param [Array] nodes
          # @return [Array] nodes to which the another nodes are related
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
            to_b = around_relations_of_one(a).find { |node, _| node == b }
            to_b && to_b.last
          end

          # @param [Array] species
          # @return [Array]
          def symmetric_close_nodes(species)
            symmetric_related_nodes(species).uniq
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
            !map_bone_relation_to(nodes).empty?
          end

          # @param [Array] nodes
          # @return [Boolean]
          def key?(nodes)
            key_nodes_lists.include?(nodes)
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
            atom_defined?(node) || specie_defined?(node)
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def atom_defined?(node)
            !!dict.var_of(node.atom)
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def specie_defined?(node)
            !!dict.var_of(node.uniq_specie)
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
          def around_relations_of(nodes)
            nodes.map(&nodes_graph.public_method(:[]))
          end

          # @param [Nodes::BaseNode] node
          # @return [Array]
          def around_relations_of_one(node)
            around_relations_of([node]).reduce(:+)
          end

          # @param [Array] nodes
          # @return [Array]
          def nodes_with_relations(nodes)
            nodes.zip(around_relations_of(nodes))
          end

          # @param [Array] nodes
          # @return [Array]
          def bone_relations_of(nodes)
            nodes_with_relations(nodes).map do |node, rels|
              rels.select { |n, _| bone_relation?(node, n) }
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Array]
          def bone_relations_of_one(node)
            bone_relations_of([node]).reduce(:+)
          end

          # @param [Array] nodes
          # @yield [Nodes::BaseNode, Concepts::Bond] each relation to each node
          # @return [Array]
          def map_bone_relation_to(nodes, &block)
            keys = key_nodes_lists.reduce(:+).reject(&nodes.public_method(:include?))
            keys.select(&method(:atom_defined?)).flat_map do |node|
              rels = bone_relations_of_one(node).select { |n, _| atom_defined?(n) }
              rels.select do |node, rel|
                nodes.include?(node) && (!block_given? || block[node, rel])
              end
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
                defined = ns.select(&method(:specie_defined?))
                defined.empty? ? ns.first : defined.first
              end
          end

          # @param [Array] nodes
          # @yield [Concepts::Bond] filter relation to selected nodes
          # @return [Array] nodes with filtered relations
          def filter_relations_to(nodes, &block)
            map_bone_relation_to(nodes) { |_, r| block[r] }.map(&:first).uniq
          end

          # @param [Array] uniq_species
          # @return [Array] lists of symmetric nodes with passed species which have
          #   bone relations to another nodes
          def symmetric_related_nodes(uniq_species)
            nodes = nodes_with_species(bone_nodes, uniq_species)
            symmetric_nodes = nodes.select(&:symmetric_atoms?)
            # exclude nodes which haven't relations to another nodes
            symmetric_nodes.select do |node|
              backbone_graph.any? { |ns, rels| related_in?(node, ns, rels) }
            end
          end

          # @param [SpecieInstance] s1
          # @param [SpecieInstance] s2
          # @return [Array]
          def atoms_pairs_for(s1, s2)
            s1.common_atoms_with(s2).reject { |as| as.uniq.one? }
          end

          # @param [Array] species_pair
          # @param [Array] atoms_pairs
          # @return [Array]
          def nodes_pairs_for(species_pair, atoms_pairs)
            atoms_pairs.map do |atoms_pair|
              species_pair.zip(atoms_pair).map { |sa| node_by(*sa) }
            end
          end

          # @param [SpecieInstance] specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom
          # @return [Nodes::BaseNode]
          def node_by(specie, atom)
            nodes_graph.keys.find { |n| n.uniq_specie == specie && n.atom == atom }
          end

          # @param [Array] nodes
          # @return [Array]
          def cut_backbone_from(nodes)
            uniq_species = nodes.map(&:uniq_specie)
            drop_proc = -> ns { nodes_without_species(ns, uniq_species) }

            reached = false
            backbone_graph.each_with_object([]) do |(key, rels), acc|
              reached ||= slice(key, rels).any? { |n| nodes.include?(n) }
              if reached
                acc << [key, rels]
              else
                acc << [drop_proc[key], rels.map { |ns, rp| [drop_proc[ns], rp] }]
              end
            end
          end

          # @param [Array] key_nodes
          # @param [Array] rels
          # @return [Array]
          def slice(key_nodes, rels)
            key_nodes + rels.flat_map(&:first)
          end

          # @param [Array] nodes
          # @param [Array] uniq_species
          # @return [Array]
          def nodes_without_species(nodes, uniq_species)
            nodes.reject { |n| specie_in?(n, uniq_species) }
          end

          # @param [Array] nodes
          # @param [Array] uniq_species
          # @return [Array]
          def nodes_with_species(nodes, uniq_species)
            nodes.select { |n| specie_in?(n, uniq_species) }
          end

          # @param [Nodes::BaseNode] node
          # @param [Array] uniq_species
          # @return [Boolean]
          def specie_in?(node, uniq_species)
            uniq_species.include?(node.uniq_specie)
          end

          # @param [Nodes::BaseNode] node
          # @param [Array] atoms
          # @return [Boolean]
          def atom_in?(node, atoms)
            atoms.include?(node.atom)
          end

          # @param [Nodes::BaseNode] node
          # @param [Array] key_nodes
          # @param [Array] rels
          # @return [Boolean]
          def related_in?(node, key_nodes, rels)
            !rels.empty? &&
              (key_nodes.include?(node) || rels.flat_map(&:first).include?(node))
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
