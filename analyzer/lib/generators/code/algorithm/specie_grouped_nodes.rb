module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for create and groups the nodes of specie algorithm graph
        class SpecieGroupedNodes < BaseGroupedNodes
          extend Forwardable

          # Initizalize grouped nodes graph of specie
          # @param [EngineCode] generator the major code generator
          # @param [Specie] specie from which the grouped nodes graph will be gotten
          def initialize(generator, specie)
            super(SpecieNodesFactory.new(generator, specie))
            @specie = specie

            @_big_links_graph, @_small_links_graph = nil
          end

        private

          def_delegator :@specie, :spec

          # Makes the nodes graph from links of target specie
          # @return [Hash] the most comprehensive graph of nodes
          def big_links_graph
            @_big_links_graph ||= transform_links(spec.clean_links)
          end

          # Makes the nodes graph from cut links of target specie
          # @return [Hash] the cutten graph of nodes
          def small_links_graph
            @_small_links_graph ||= transform_links(@specie.essence.cut_links)
          end

          # Detects relation between passed nodes
          # @param [Array] nodes the array with two nodes between which the relation
          #   will be detected
          # @return [Concepts::Bond] the relation between atoms from passed nodes
          def relation_between(*nodes)
            atoms = nodes.map(&:atom)
            spec.relation_between(*atoms)
          end
        end

      end
    end
  end
end
