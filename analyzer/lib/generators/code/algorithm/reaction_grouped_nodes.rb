module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for create nodes of reaction and group them by parameters
        # of relations
        class ReactionGroupedNodes < BaseGroupedNodes
          # Initizalize grouper by reaction class code generator
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction from which grouped graph will be gotten
          def initialize(generator, reaction)
            super(ReactionNodesFactory.new(generator, reaction))
            @reaction = reaction

            @_big_links_graph, @_small_links_graph = nil
          end

        private

          # Makes the nodes graph from links of target reaction
          # @return [Hash] the most comprehensive graph of nodes
          def big_links_graph
            @_big_links_graph ||= transform_links(@reaction.original_links)
          end

          # Makes the nodes graph from positions of target reaction
          # @return [Hash] the small graph of nodes
          def small_links_graph
            @_small_links_graph ||= transform_links(@reaction.clean_links)
          end

          # Detects relation between passed nodes
          # @param [Array] nodes the array with two nodes between which the relation
          #   will be detected
          # @return [Concepts::Bond] the relation between atoms from passed nodes
          def relation_between(*nodes)
            specs_atoms = nodes.map { |n| [n.uniq_specie.spec.spec, n.atom] }
            @reaction.relation_between(*specs_atoms)
          end
        end

      end
    end
  end
end
