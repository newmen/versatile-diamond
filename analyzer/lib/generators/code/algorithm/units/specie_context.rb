module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of specie find algoritnm builder
        class SpecieContext < BaseContext
          include Modules::GraphDupper

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [Hash] nodes_graph
          # @param [Array] ordered_backbone
          def initialize(dict, nodes_graph, ordered_backbone)
            super
            @_converted_nodes_graph = nil
            @_converted_backbone_graph = nil
          end

        private

          # @return [Hash]
          # @override
          def nodes_graph
            @_converted_nodes_graph ||=
              super.each_with_object({}) do |(node, rels), acc|
                changed_rels = replace_rels(rels)
                replace_scopes([node]).each do |n|
                  acc[n] ||= []
                  acc[n] = (acc[n] + changed_rels).uniq
                end
              end
          end

          # @return [Hash]
          # @override
          def backbone_graph
            @_converted_backbone_graph ||= dup_graph(super, &method(:replace_scopes))
          end

          # @param [Array] rels
          # @return [Array]
          def replace_rels(rels)
            rels.flat_map do |node, rel|
              replace_scopes([node]).map { |n| [n, rel] }
            end
          end

          # @param [Array] nodes
          # @return [Array]
          def replace_scopes(nodes)
            nodes.flat_map(&:split)
          end

          # @param [Nodes::BaseNode] node
          # @param [Array] _ automatically passed to super method
          # @return [Boolean]
          # @override
          def related_in?(node, *)
            node.splittable? || super
          end
        end

      end
    end
  end
end
