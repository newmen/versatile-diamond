module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of find algoritnm builder
        # @abstract
        class BaseContext
          include Modules::ListsComparer

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Array] ordered_backbone
          def initialize(dict, ordered_backbone)
            @dict = dict
            @backbone_graph = Hash[ordered_backbone]

            @_all_nodes = nil
          end

          # @param [Array] atoms
          # @return [Array]
          def atom_nodes(atoms)
            all_nodes.select { |node| atoms.include?(node.atom) }
          end

          # @param [Instance::SpecieInstance] specie
          # @return [Array]
          def specie_nodes(specie)
            all_nodes.select { |node| node.uniq_specie == specie }
          end

          # @param [Array] species
          # @return [Array]
          def reachable_nodes_with(species)
            all_nodes.select { |node| undefined_atom_in?(node, species) }
          end

          # @param [Array] species
          # @return [Array]
          def symmetric_close_nodes(species)
            bulk_key_nodes_with(species).select(&method(:all_symmetric_atoms?))
          end

          # @param [Array] nodes
          # @return [Boolean]
          def symmetric_relations?(nodes)
            if nodes.empty?
              raise ArgumentError, 'Empty nodes list passed'
            elsif !nodes.one?
              rels_lists = relations_of(nodes)
              !rels_lists.any?(&:empty?) && same_relations?(rels_lists) &&
                same_side_props?(rels_lists) && same_side_species?(rels_lists)
            else
              false
            end
          end

        private

          attr_reader :backbone_graph

          # @return [Array]
          def all_nodes
            @_all_nodes ||= (backbone_graph.keys + side_nodes_lists).flatten.uniq
          end

          # @return [Array]
          def side_nodes_lists
            backbone_graph.values.flat_map { |rels| rels.map(&:first) }
          end

          # @param [Array] uniq_species
          # @return [Array]
          def bulk_key_nodes_with(uniq_species)
            undefined_related_nodes(uniq_species).uniq(&:to_set)
          end

          # @param [Array] uniq_species
          # @return [Array] lists of related nodes with undefined atoms
          def undefined_related_nodes(uniq_species)
            key_nodes = backbone_graph.keys
            undefined_atoms_nodes(key_nodes, uniq_species).flat_map do |nodes|
              same_related_nodes(nodes).map { |ns| nodes + ns }
            end
          end

          # @param [array] nodes
          # @return [array]
          def same_related_nodes(nodes)
            node_species = nodes.flat_map(&:uniq_specie).uniq
            original_species = node_species.map(&:original)
            nbrs_lists = backbone_graph[nodes].map(&:first)
            same_nbrs = nbrs_lists.select do |ns|
              ns.all? do |node|
                !@dict.var_of(node.atom) &&
                  original_species.include?(node.uniq_specie.original)
              end
            end
          end

          # @param [Array] nodes_lists
          # @param [Array] uniq_species
          # @return [Array]
          def undefined_atoms_nodes(nodes_lists, uniq_species)
            nodes_lists.select do |nodes|
              nodes.all? { |node| undefined_atom_in?(node, uniq_species) }
            end
          end

          # @param [Nodes::BaseNode] node
          # @param [Array] uniq_species
          # @return [Boolean]
          def undefined_atom_in?(node, uniq_species)
            uniq_species.include?(node.uniq_specie) && !@dict.var_of(node.atom)
          end

          # @param [Array] rels_lists
          # @return [Boolean]
          def same_relations?(rels_lists)
            same_rels_when?(rels_lists) { |rels| rels.map(&:last).select(&:exist?) }
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_side_props?(rels_lists)
            same_rels_when?(rels_lists) do |rels|
              rels.map(&:first).map(&:first).map(&:properties)
            end
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_side_species?(rels_lists)
            same_rels_when?(rels_lists) do |rels|
              rels.map(&:first).map(&:first).map(&:uniq_specie).map(&:original)
            end
          end

          # @return [Array] rels_lists
          # @yield [Array] transforms the relations list
          # @return [Boolean]
          def same_rels_when?(rels_lists, &block)
            lists_are_identical?(*rels_lists.map(&block), &:==)
          end

          # @param [Array] nodes
          # @return [Boolean]
          def all_symmetric_atoms?(nodes)
            if same_specie_nodes?(nodes)
              one_specie_symmetric_atoms?(nodes)
            else
              many_species_symmetric_atoms?(nodes)
            end
          end

          # @param [Array] nodes
          # @return [Boolean]
          def same_specie_nodes?(nodes)
            nodes.map(&:uniq_specie).map(&:original).uniq.one?
          end

          # @param [Array] nodes
          # @return [Boolean]
          def one_specie_symmetric_atoms?(nodes)
            symmetries_lists = nodes.map(&:symmetric_atoms)
            !symmetries_lists.any?(&:empty?) &&
              lists_are_identical?(*([nodes.map(&:atom)] + symmetries_lists), &:==)
          end

          # @param [Array] nodes
          # @return [Boolean]
          def many_species_symmetric_atoms?(nodes)
            nodes.map(&:uniq_specie).uniq(&:original).one? &&
              nodes.map(&:properties).uniq.one? &&
              symmetric_relation_between?(*nodes)
          end

          # @param [Nodes::BaseNode] a
          # @param [Nodes::BaseNode] b
          # @return [Boolean]
          def symmetric_relation_between?(a, b)
            to_b = relations_of([a]).find { |node, _| node == b }
            if to_b
              ab_relation = to_b.last
              ba_relation = b.lattice.opposite_relation(a.lattice, ab_relation)
              ab_relation == ba_relation
            else
              false
            end
          end
        end

      end
    end
  end
end
