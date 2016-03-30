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
                  acc[n] += changed_rels
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
            rels.each_with_object([]) do |(node, rel), acc|
              replace_scopes([node]).each { |n| acc << [n, rel] }
            end
          end

          # @param [Array] nodes
          # @return [Array]
          def replace_scopes(nodes)
            nodes.reduce([]) do |acc, node|
              node.scope? ? (acc + node.split) : (acc << node)
            end
          end
        end

      end
    end
  end
end
