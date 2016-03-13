module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of find algoritnm builder
        # @abstract
        class BaseContext
          include Modules::ListsComparer
          extend Forwardable

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Array] ordered_backbone
          def initialize(dict, ordered_backbone)
            @dict = dict
            @backbone_graph = Hash[ordered_backbone]
          end

          # @param [Array] species
          # @return [Array]
          def reachable_nodes_with(species)
            nodes = all_nodes_lists.flatten
            nodes.select { |node| undefined_atom_in?(node, species) }.uniq
          end

          # @param [Array] species
          # @return [Array]
          def symmetric_close_nodes(species)
            bulk_key_nodes_with(species).select(&method(:all_symmetric_atoms?))
          end

          # @param [Array] nodes
          # @return [Boolean]
          def symmetric_relations?(nodes)
            rels = relations_of(nodes)
            same_relations?(rels) &&
              same_side_props?(rels) && same_side_species?(rels_lists)
          end

        private

          attr_reader :backbone_graph

          # @return [Array]
          def all_nodes_lists
            backbone_graph.keys +
              backbone_graph.values.flat_map { |rels| rels.map(&:first) }
          end

          # @param [Array] uniq_species
          # @return [Array]
          def bulk_key_nodes_with(uniq_species)
            nodes_lists = backbone_graph.keys
            result = undefined_atoms_nodes(nodes_lists, uniq_species).reject(&:one?)
            result.uniq(&:to_set)
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
            same_rels_when? { |rels| rels.map(&:last).select(&:exist?) }
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_side_props?(rels_lists)
            same_rels_when? { |rels| rels.map(&:first).map(&:properties) }
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_side_species?(rels_lists)
            same_rels_when? do |rels|
              rels.map(&:first).map(&:uniq_specie).map(&:original)
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
            nodes.map(&:uniq_specie).uniq.one?
          end

          # @param [Array] nodes
          # @return [Boolean]
          def one_specie_symmetric_atoms?(nodes)
            nodes_atoms = nodes.map(&:atom)
            symmetries_lists = nodes_atoms.map(&method(:symmetries_of))
            !symmetries_lists.first.empty? &&
              lists_are_identical?(*(nodes_atoms + symmetries_lists), &:==)
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
