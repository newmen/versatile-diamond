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
            @_converted_backbone_graph ||=
              dup_graph(super, &method(:replace_scopes)).freeze
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

          # @param [Array] _
          # @return [Array]
          # @override
          def nodes_pairs_for(*)
            super.reject do |n1, n2|
              same_splitten_species?(n1, n2) || same_splitten_species?(n2, n1)
            end
          end

          # @param [Nodes::BaseNode] n1
          # @param [Nodes::BaseNode] n2
          # @return [Boolean]
          def same_splitten_species?(n1, n2)
            n1.split.map(&:uniq_specie).include?(n2.uniq_specie)
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
