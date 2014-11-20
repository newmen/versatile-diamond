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
            super(ReactionNodesFactory.new(generator))
            @reaction = reaction

            @_big_graph, @_small_graph = nil
          end

          # Makes the nodes graph from original links between interacting atoms of
          # target reaction
          #
          # @return [Hash] the most comprehensive graph of nodes
          def big_graph
            @_big_graph ||= transform_links(@reaction.original_links)
          end

        private

          # Makes the nodes graph from positions of target reaction
          # @return [Hash] the small graph of nodes
          def small_graph
            return @_small_graph if @_small_graph

            result = transform_links(@reaction.clean_links)
            if result.empty?
              surf_changes = @reaction.changes.reject do |(s1, _), (s2, _)|
                bad_spec?(s1) || bad_spec?(s2)
              end
              result = transform_links(surf_changes.map { |sa, _| [sa, []] })
            end

            @_small_graph = result
          end

          # Checks that passed spec is bad
          # @param [Concepts::Spec | Concepts::SpecificSpec] spec which will be checked
          # @return [Boolean] is passed spec bad or not
          def bad_spec?(spec)
            spec.simple? || spec.gas?
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
