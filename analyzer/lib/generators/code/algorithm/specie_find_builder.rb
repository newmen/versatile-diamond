module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building find specie algorithm
        class SpecieFindBuilder < MainFindAlgorithmBuilder

          # Inits builder by target specie and main engine code generator
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie the target specie code generator
          def initialize(generator, specie)
            @specie = specie
            @backbone = SpecieBackbone.new(generator, specie)
            @dict = Units::Expressions::VarsDictionary.new

            @pure_factory = SpeciePureUnitsFactory.new(@dict)
          end

          # Generates find algorithm cpp code for target specie
          # @return [String] the string with cpp code of find specie algorithm
          def build
            @dict.checkpoint!
            @backbone.entry_nodes.map(&method(:body_for)).join
          end

        private

          # @param [Array] ordered_graph
          # @return [Units::SpecieContext]
          def specie_context(ordered_graph)
            Units::SpecieContext.new(@dict, @specie, ordered_graph)
          end

          # @param [Array] ordered_graph
          # @return [SpecieUnitsFactoryWithContext]
          def context_factory(ordered_graph)
            SpecieUnitsFactoryWithContext.new(@dict, specie_context(ordered_graph))
          end

          # Generates the body of code from passed nodes
          # @param [Array] nodes from which the code will be generated
          # @return [String] the algorithm of finding current specie from passed nodes
          def body_for(nodes)
            @dict.rollback!
            @pure_factory.unit(nodes).entry_point!
            combine_algorithm(nodes)
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] nodes by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(nodes)
            graph = @backbone.ordered_graph_from(nodes)
            factory = context_factory(graph)

            init = [check_atoms_proc(factory.unit(nodes))]
            graph.reduce(init) do |acc, (ns, rels)|
              unit = factory.unit(ns)
              acc + [check_species_proc(unit)] +
                accumulate_relations(factory, unit, rels)
            end
          end

          # @param [Units::BaseUnit] unit the roles of which atoms will be checked
          # @return [Proc]
          def check_atoms_proc(unit)
            -> &block { unit.check_existence(&block) }
          end

          # @param [Units::BaseUnit] unit
          # @return [Proc] lazy calling for check species unit method
          def check_species_proc(unit)
            -> &block { unit.check_avail_species(&block) }
          end
        end

      end
    end
  end
end
