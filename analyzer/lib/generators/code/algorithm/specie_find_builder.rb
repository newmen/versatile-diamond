module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building find specie algorithm
        class SpecieFindBuilder < BaseFindBuilder
          extend Forwardable

          def_delegator :backbone, :using_atoms

          # Inits builder by target specie and main engine code generator
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie the target specie code generator
          def initialize(generator, specie)
            @specie = specie
            super(generator)
          end

          # Generates find algorithm cpp code for target specie
          # @return [String] the string with cpp code of find specie algorithm
          def build
            entry_nodes_with_elses.reduce('') do |acc, (nodes, else_prefix)|
              factory.reset!
              acc + body_for(nodes, else_prefix)
            end
          end

        private

          # Creates backbone of algorithm
          # @return [SpecieBackbone] the backbone which provides ordered graph
          def create_backbone
            SpecieBackbone.new(generator, @specie)
          end

          # Creates factory of units for algorithm generation
          # @return [SpecieUnitsFactory] correspond units factory
          def create_factory
            SpecieUnitsFactory.new(generator, @specie)
          end

          # Gets entry nodes zipped with else prefixes for many ways condition
          # @return [Array] entry nodes zipped with else prefixes
          def entry_nodes_with_elses
            ens = backbone.entry_nodes
            ens.zip([''] + ['else '] * (ens.size - 1))
          end

          # @return [String]
          def body_for(nodes, else_prefix)
            unit = factory.make_unit(nodes)
            unit.first_assign!

            unit.check_existence(else_prefix) do
              combine_algorithm(nodes)
            end
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] nodes by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(nodes)
            backbone.ordered_graph_from(nodes).reduce([]) do |acc, (ns, rels)|
              acc << species_proc(ns)
              acc + accumulate_relations(ns, rels)
            end
          end

          # @return [Proc] lazy calling for check species unit method
          def species_proc(nodes)
            unit = factory.make_unit(nodes)
            -> &block { unit.check_species(&block) }
          end
        end

      end
    end
  end
end
