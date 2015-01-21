module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building check sidepiece specie algorithm
        class SidepieceCheckBuilder < BaseFindBuilder

          # Inits builder by target where logic object and main engine code generator
          # @param [EngineCode] generator the major engine code generator
          # @param [WhereLogic] where the target where logic code generator
          def initialize(generator, where)
            @where = where
            super(generator)
          end

          # Generates find algorithm cpp code for target where logic object
          # @return [String] the string with cpp code of check sidepiece specie
          #   algorithm
          def build
            nodes = backbone.entry_nodes
            unit = factory.make_unit(nodes)
            unit.first_assign!

            unit.check_symmetries do
              combine_algorithm(nodes)
            end
          end

        private

          # Creates backbone of algorithm
          # @return [SpecieBackbone] the backbone which provides ordered graph
          def create_backbone
            WhereBackbone.new(generator, @where)
          end

          # Creates factory of units for algorithm generation
          # @return [SpecieUnitsFactory] correspond units factory
          def create_factory
            WhereUnitsFactory.new(generator, @where)
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
