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
          def symmetric_close_nodes(species)
            nodes = key_nodes_with(species).uniq(&:to_set)
            nodes.select(&method(:all_symmetric_atoms?))
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

          # @param [Array] uniq_species
          # @return [Array]
          def key_nodes_with(uniq_species)
            nodes_with_undefined_atoms_of(uniq_species).select do |nodes|
              !nodes.one? &&
                nodes.all? { |node| uniq_species.include?(node.uniq_specie) }
            end
          end

          # @param [Array] uniq_species
          # @return [Array]
          def nodes_with_undefined_atoms_of(uniq_species)
            backbone_graph.keys.reject do |nodes|
              nodes.map(&:atom).any? { |atom| @dict.var_of(atom) }
            end
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
