module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building find reaction algorithm
        class ReactionFindBuilder < BaseFindBuilder

          # Inits builder by main engine code generator, target reaction and reatant
          # specie which should be found by generating algorithm
          #
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          # @param [Specie] specie the reactant which will be found by algorithm
          def initialize(generator, reaction, specie)
            @reaction = reaction
            @specie = @specie
            super(generator)
          end

          # Generates find algorithm cpp code for target reaction
          # @return [String] the string with cpp code of find reaction algorithm
          def build
            nodes = entry_nodes
            unit = factory.make_unit(nodes)
            unit.first_assign!

            combine_algorithm(nodes)
          end

        private

          # Creates backbone of algorithm
          # @return [SpecieBackbone] the backbone which provides ordered graph
          def create_backbone
            ReactionBackbone.new(generator, @reaction, @specie)
          end

          # Creates factory of units for algorithm generation
          # @return [ReactionUnitsFactory] correspond units factory
          def create_factory
            ReactionUnitsFactory.new(generator, @reaction)
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] nodes by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(nodes)
            ordered_graph_from(nodes).reduce([]) do |acc, (ns, rels)|
              acc + accumulate_relations(ns, rels)
            end
          end
        end

      end
    end
  end
end
