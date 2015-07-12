module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the look around algorithm will be builded
        class LookAroundBackbone < LateralChunksBackbone
        private

          # Makes clean graph with relations only from target nodes
          # @return [Hash] the grouped graph with relations only from target nodes
          def make_final_graph
            grouped_graph.select { |nodes, _| target_nodes?(nodes) }
          end

          # Checks that passed nodes contains specs which belongs to target specs
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes contain target spec
          def target_nodes?(nodes)
            nodes.all? { |node| lateral_chunks.target_spec?(node.dept_spec.spec) }
          end
        end

      end
    end
  end
end
