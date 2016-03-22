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

            @_uniq_nodes = nil
          end

          # @param [Array] atoms
          # @return [Array]
          def atoms_nodes(atoms)
            uniq_nodes.select { |node| atoms.include?(node.atom) }
          end

          # @param [Instance::SpecieInstance] specie
          # @return [Array]
          def specie_nodes(specie)
            uniq_nodes.select { |node| node.uniq_specie == specie }
          end

          # @param [Array] species
          # @return [Array]
          def reachable_nodes_with(species)
            uniq_nodes.select { |node| undefined_atom_in?(node, species) }
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
          def uniq_nodes
            @_uniq_nodes ||= all_nodes.uniq
          end

          # @return [Array]
          def all_nodes
            (backbone_graph.keys + side_nodes_lists).flatten
          end

          # @return [Array]
          def side_nodes_lists
            backbone_graph.values.flat_map { |rels| rels.map(&:first) }
          end

          # @param [Array] uniq_species
          # @return [Array] lists of related nodes with undefined atoms
          def undefined_related_nodes(uniq_species)
            nodes_lists = undefined_atoms_nodes(backbone_graph.keys, uniq_species)
            nodes_lists.select(&method(:undefined_symmetric_atoms?))
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
