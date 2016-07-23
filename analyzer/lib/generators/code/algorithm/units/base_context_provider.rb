module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

        # The context for units of find algoritnm builder
        # @abstract
        class BaseContextProvider
          include Modules::ListsComparer

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Hash] nodes_graph
          # @param [Array] ordered_backbone
          def initialize(dict, nodes_graph, ordered_backbone)
            @dict = dict
            @nodes_graph = nodes_graph
            @backbone_graph = Hash[ordered_backbone]
            @ordered_graph = ordered_backbone

            @_key_nodes_lists, @_side_nodes_lists = nil
            @_uniq_nodes = nil
          end

          # @return [Array]
          def bone_nodes
            @_uniq_nodes ||= splitten_nodes.flatten.uniq
          end

          # @param [Array] species
          # @return [Array]
          def species_nodes(species)
            bone_nodes.select { |node| specie_in?(node, species) }
          end

          # @param [Array] species
          # @return [Array]
          def many_times_reachable_nodes(species)
            species_nodes(species).select(&method(:many_times_reachable?))
          end

          # Gets nodes which belongs to checking nodes but have existed relations from
          # target nodes which are not same as checking
          #
          # @param [Array] target_nodes
          # @param [Array] checking_nodes
          # @return [Array] nodes to which the another nodes are related
          def existed_relations_to(target_nodes, checking_nodes)
            filter_relations_to(target_nodes, checking_nodes, &:exist?)
          end

          # Gets nodes which belongs to checking nodes but have not existed relations
          # from target nodes which are not same as checking
          #
          # @param [Array] target_nodes
          # @param [Array] checking_nodes
          # @return [Array] nodes to which the another nodes are related
          def not_existed_relations_to(target_nodes, checking_nodes)
            filter_relations_to(target_nodes, checking_nodes) { |rel| !rel.exist? }
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
              different = sides.reject { |ns| ns.map(&:uniq_specie).uniq.one? }
              likes = different.select(&method(:similar_properties?))
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
              rels_lists = both_directions_bone_relations_of(nodes)
              similar_relations?(rels_lists)
            else
              false
            end
          end

          # @param [Array] rels_lists
          # @return [Boolean]
          def similar_relations?(rels_lists)
            !rels_lists.any?(&:empty?) &&
              same_existing_relations?(rels_lists) && same_side_props?(rels_lists)
          end

          # @param [Array] target_nodes
          # @param [Array] checking_nodes
          # @return [Boolean]
          def related_from_other_defined?(target_nodes, checking_nodes)
            !map_bone_relation_to(target_nodes, checking_nodes).empty?
          end

          # @param [Array] nodes
          # @return [Boolean]
          def key?(nodes)
            key_nodes_lists.include?(nodes)
          end

          # @param [Array] cutting_nodes
          # @param [Array] target_nodes
          # @return [Boolean]
          def cutten_bone_relations_from?(cutting_nodes, target_nodes)
            cut_backbone_from(cutting_nodes).map(&:first).include?(target_nodes)
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def just_existed_bone_relations?(node)
            both_directions_bone_relations_of_one(node).all? { |_, r| r.exist? }
          end

        private

          attr_reader :dict, :nodes_graph, :backbone_graph, :ordered_graph

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
          # @return [Array]
          def both_directions_bone_relations_of(nodes)
            nodes.map do |node|
              around_relations_of_one(node).select do |n, _|
                bone_relation?(node, n) || bone_relation?(n, node)
              end
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Array]
          def both_directions_bone_relations_of_one(node)
            both_directions_bone_relations_of([node]).reduce(:+)
          end

          # @param [Array] target_nodes
          # @param [Array] checking_nodes
          # @yield [Nodes::BaseNode, Concepts::Bond] each relation to each node
          # @return [Array]
          def map_bone_relation_to(target_nodes, checking_nodes, &block)
            skipping_nodes = species_nodes(target_nodes.map(&:uniq_specie).uniq)
            skipping_proc = skipping_nodes.public_method(:include?)
            keys = key_nodes_lists.reduce(:+).reject(&skipping_proc)
            keys.select(&method(:atom_defined?)).flat_map do |node|
              rels = bone_relations_of_one(node).select { |n, _| atom_defined?(n) }
              rels.select do |n, r|
                checking_nodes.include?(n) && (!block_given? || block[n, r])
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

          # @param [Array] target_nodes
          # @param [Array] checking_nodes
          # @yield [Concepts::Bond] filter relation to checking nodes
          # @return [Array] checking nodes with filtered relations
          def filter_relations_to(target_nodes, checking_nodes, &block)
            selected_nodes =
              map_bone_relation_to(target_nodes, checking_nodes) { |_, r| block[r] }
            selected_nodes.map(&:first).uniq
          end

          # @param [Array] uniq_species
          # @return [Array] lists of symmetric nodes with passed species which have
          #   bone relations to another nodes
          def symmetric_related_nodes(uniq_species)
            nodes = nodes_with_species(bone_nodes, uniq_species)
            symmetric_nodes = nodes.select(&:symmetric_atoms?)
            same_related_nodes(symmetric_nodes)
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
          # @return [Hash]
          def cut_backbone_from(nodes)
            uniq_species = nodes.map(&:uniq_specie)
            drop_proc = -> ns { nodes_without_species(ns, uniq_species) }

            reached = false
            ordered_graph.each_with_object([]) do |(key, rels), acc|
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

          # @param [Array] rels_lists
          # @return [Boolean]
          def same_existing_relations?(rels_lists)
            same_rels_when?(rels_lists) { |rels| rels.map(&:last).select(&:exist?) }
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_side_props?(rels_lists)
            same_rels_when?(rels_lists) { |rels| rels.map(&:first).map(&:properties) }
          end

          # @return [Array] rels_lists
          # @yield [Array] transforms the relations list
          # @return [Boolean]
          def same_rels_when?(rels_lists, &block)
            lists_are_identical?(*rels_lists.map(&block))
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
          def both_units_related?(node, nodes)
            accurate_related?([node], nodes) || accurate_related?(nodes, [node])
          end

          # @param [Array] nodes1
          # @param [Array] nodes2
          # @return [Boolean]
          def accurate_related?(nodes1, nodes2)
            backbone_graph.any? do |key, rels|
              lists_are_identical?(nodes1, key) &&
                rels.any? { |ns, _| lists_are_identical?(nodes2, ns) }
            end
          end

          # @return [Array] nodes
          # @return [Boolean]
          def similar_properties?(nodes)
            nodes.each_cons(2).all? do |a, b|
              a.atom != b.atom && a.properties.like?(b.properties)
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def many_times_reachable?(node)
            (key_then_side_reachable?(node) && !direct_reachable?(node)) ||
              first_rejected_side_reachable?(node) || many_sides_reachable?(node)
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def key_then_side_reachable?(node)
            check_proc = using_in_proc(node)
            was_key = false
            backbone_graph.any? do |key, rels|
              if check_proc[key]
                was_key = true
                false # block result
              elsif was_key
                rels.map(&:first).any?(&check_proc)
              else
                false
              end
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def direct_reachable?(node)
            check_proc = using_in_proc(node)
            backbone_graph.any? do |key, rels|
              check_proc[key] && rels.any? { |ns, _| ns.include?(node) }
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def first_rejected_side_reachable?(node)
            check_proc = using_in_proc(node)
            result = false
            backbone_graph.each do |key, rels|
              if check_proc[key]
                break
              elsif rejected_relations_with?(node, key, rels)
                result = true
                break
              end
            end
            result
          end

          # @param [Nodes::BaseNode] node
          # @param [Array] key
          # @param [Array] rels
          # @return [Boolean]
          def rejected_relations_with?(node, key, rels)
            rels.any? do |ns, _|
              ns.include?(node) && key.any? do |k|
                relation = relation_between(k, node)
                relation && !relation.exist?
              end
            end
          end

          # @param [Nodes::BaseNode] node
          # @return [Boolean]
          def many_sides_reachable?(node)
            check_proc = using_in_proc(node)
            !key_nodes_lists.any?(&check_proc) &&
              side_nodes_lists.select(&check_proc).size > 1
          end

          # @param [Nodes::BaseNode] node
          # @return [Proc]
          def using_in_proc(node)
            -> nodes { specie_in?(node, nodes.map(&:uniq_specie)) }
          end
        end

      end
    end
  end
end
