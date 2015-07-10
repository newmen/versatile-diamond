module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the look around algorithm will be builded
        class ChunksBackbone < BaseBackbone

          # Initializes backbone by lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object for which the graph
          #   will be builded
          def initialize(generator, lateral_chunks)
            super(ChunksGroupedNodes.new(generator, lateral_chunks))
            @lateral_chunks = lateral_chunks

            @_final_graph = nil
          end

          # Gets entry nodes for generating algorithm
          # @return [Array] the array of entry nodes
          def entry_nodes
            [final_graph.keys.find(&method(:all_target_specs?))]
          end

          # Makes clean graph with relations only from species of target reaction
          # @return [Hash] the grouped graph with relations only from species of
          #   target reaction
          # TODO: must be private!
          def final_graph
            @_final_graph ||= super.select { |nodes, _| all_target_specs?(nodes) }
          end

        private

          # Gets the concept spec from node
          # @param [Node] node from which the concept spec will be gotten
          # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          def concept_spec(node)
            node.dept_spec.spec
          end

          # Also checks that nodes in relations belongs to just one unit chunk
          # @param [Array] _nodes which properties and relations checks
          # @param [Array] rels the relations of passed nodes
          # @return [Boolean] is nodes should be reordering much optimal or not
          # @override
          def maximal_rels?(_nodes, rels)
            return false unless super
            specs = rels.flat_map(&:first).map(&method(:concept_spec))
            @lateral_chunks.count_chunks(specs) == 1
          end

          # Checks that passed nodes contains specs which belongs to target specs
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes contain target spec
          def all_target_specs?(nodes)
            nodes.all? { |node| @lateral_chunks.target_spec?(concept_spec(node)) }
          end
        end

      end
    end
  end
end
