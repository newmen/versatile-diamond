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
            @backbone = SpecieBackbone.new(generator, @specie)
            @dict = Units::Expressions::VarsDictionary.new

            @pure_factory = SpeciePureUnitsFactory.new(@dict)
          end

          # Generates find algorithm cpp code for target specie
          # @return [String] the string with cpp code of find specie algorithm
          def build
            @dict.checkpoint!
            backbone.entry_nodes.map(&method(:body_for)).map(&:shifted_code).join
          end

        private

          attr_reader :backbone

          # @param [Array] ordered_graph
          # @return [Units::SpecieContextProvider]
          def specie_context(ordered_graph)
            Units::SpecieContextProvider.new(@dict, backbone.big_graph, ordered_graph)
          end

          # @param [Units::SpecieContextProvider] context
          # @return [SpecieUnitsFactoryWithContext]
          def context_factory(context)
            SpecieUnitsFactoryWithContext.new(@dict, context)
          end

          # Generates the body of code from passed nodes
          # @param [Array] nodes from which the code will be generated
          # @return [String] the algorithm of finding current specie from passed nodes
          def body_for(nodes)
            @dict.rollback!
            @pure_factory.unit(nodes).define!
            combine_algorithm(nodes)
          end

          # @oaram [SpecieUnitsFactoryWithContext] factory
          # @param [Array] nodes
          # @return [Array]
          def init_procs(factory, nodes)
            [check_atoms_proc(factory.unit(nodes))]
          end

          # Collects procs of conditions for body of find algorithm
          # @param [SpecieUnitsFactoryWithContext] factory
          # @param [Array] ordered_graph
          # @param [Array] init_procs
          # @return [Array] the array of procs which will combined later
          def collect_procs(factory, ordered_graph, init_procs)
            ordered_graph.reduce(init_procs) do |acc, (ns, rels)|
              unit = factory.unit(ns)
              nbrs = nbrs_units(factory, rels)
              acc + [check_species_proc(unit)] + accumulate_relations(unit, nbrs)
            end
          end

          # @oaram [SpecieUnitsFactoryWithContext] factory
          # @param [Array] rels
          # @return [Array]
          def nbrs_units(factory, rels)
            rels.map(&:first).map(&factory.public_method(:unit))
          end

          # @param [Units::BasePureUnit] unit the roles of which atoms will be checked
          # @return [Proc]
          def check_atoms_proc(unit)
            -> &block { unit.check_existence(&block) }
          end

          # @param [Units::BaseContextUnit] unit
          # @return [Proc] lazy calling for check species unit method
          def check_species_proc(unit)
            -> &block { unit.check_avail_species(&block) }
          end

          # @param [Units::SpecieContextProvider] context
          # @return [Expressions::Core::Statement]
          def creator(context)
            Units::SpecieCreationUnit.new(@dict, context, @specie)
          end
        end

      end
    end
  end
end
