module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction look around algorithm
        class ReactionLookAroundBuilder < BaseFindBuilder
          # Inits builder by main engine code generator and lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(generator, lateral_chunks)
            @lateral_chunks = lateral_chunks
            super(generator)
          end

          # Generates look around algorithm cpp code for target lateral chunks
          # @return [String] the string with cpp code of look around reaction algorithm
          def build
          end

        private

          # Creates backbone of algorithm
          # @return [SpecieBackbone] the backbone which provides ordered graph
          def create_backbone
            ChunksBackbone.new(generator, @lateral_chunks)
          end

          # Creates factory of units for algorithm generation
          # @return [ReactionUnitsFactory] correspond units factory
          def create_factory
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] nodes by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(nodes)
            ordered_graph = backbone.ordered_graph_from(nodes)
            ordered_graph.reduce([]) do |acc, (ns, rels)|
              acc + accumulate_relations(ns, rels)
            end
          end
        end

      end
    end
  end
end
