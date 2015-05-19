module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for group the nodes of where object by parameters of relations
        class WhereGroupedNodes < BaseGroupedNodes

          # Initizalize grouper by where logic code generator
          # @param [EngineCode] generator the major code generator
          # @param [WhereLogic] where logic object from which links the grouped graph
          #   will be maked
          def initialize(generator, where)
            super(WhereNodesFactory.new(generator, where.original_links))
            @where = where

            @_big_graph, @_small_graph = nil
          end

          # Removes non target nodes from keys of result graph
          # @return [Hash] the grouped nodes graph but without non target nodes in
          #   keys of graph
          # @override
          def final_graph
            super.each_with_object({}) do |(nodes, rels), acc|
              acc[nodes] = rels if nodes.all?(&:none?)
            end
          end

          # Makes the nodes graph from original links between interacting atoms of
          # target where object
          #
          # @return [Hash] the most comprehensive graph of nodes
          def big_graph
            @_big_graph ||= transform_links(@where.links)
          end

        private

          # Makes the nodes graph from positions of target where
          # @return [Hash] the small graph of nodes
          def small_graph
            @_small_graph ||= transform_links(@where.clean_links)
          end

          # Detects relation between passed nodes
          # @param [Array] nodes the array with two nodes between which the relation
          #   will be detected
          # @return [Concepts::Bond] the relation between atoms from passed nodes
          def relation_between(*nodes)
            vertices = nodes.map do |node|
              node.none? ? node.atom : [node.uniq_specie.spec.spec, node.atom]
            end
            @where.relation_between(*vertices)
          end
        end

      end
    end
  end
end
