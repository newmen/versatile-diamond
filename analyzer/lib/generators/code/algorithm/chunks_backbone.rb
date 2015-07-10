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

          # Checks that passed nodes contains specs which belongs to target specs
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes contain target spec
          def all_target_specs?(nodes)
            nodes.all? { |node| @lateral_chunks.target_spec?(node.dept_spec.spec) }
          end
        end

      end
    end
  end
end
