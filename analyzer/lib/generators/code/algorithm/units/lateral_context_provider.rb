module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of lateral find algoritnm builder
        class LateralContextProvider < ReactionContextProvider
          include Mcs::SpecsAtomsComparator

          attr_reader :action_nodes

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Hash] nodes_graph
          # @param [Array] ordered_graph
          def initialize(dict, nodes_graph, ordered_graph, action_nodes)
            super(dict, nodes_graph, ordered_graph)
            @action_nodes = action_nodes.uniq(&:spec_atom)
          end

          # @return [Array]
          def key_nodes
            key_nodes_lists.reduce(:+).reject(&:side?).uniq
          end

          # @return [Array]
          def side_nodes
            side_nodes_lists.reduce(:+).select(&:side?).uniq
          end

          # @return [Boolean]
          def symmetric_actions?
            sas = action_nodes.map(&:spec_atom)
            !sas.one? && same_sa?(*sas) &&
              !similar_relations?(side_relations_of(action_nodes))
          end

          # @param [Array] rels_lists
          # @return [Boolean]
          # @override
          def similar_relations?(rels_lists)
            super && same_otherside_specs?(rels_lists)
          end

        private

          # @param [Array] nodes
          # @return [Array]
          def side_relations_of(nodes)
            around_relations_of(nodes).map do |ns|
              ns.select { |n, _| n.side? }
            end
          end

          # @return [Array] rels_lists
          # @return [Boolean]
          def same_otherside_specs?(rels_lists)
            same_rels_when?(rels_lists) do |rels|
              rels.map(&:first).map(&:spec).map(&:spec)
            end
          end
        end

      end
    end
  end
end
