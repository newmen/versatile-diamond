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
            super(SpecieBackbone.new(generator, specie))
            @specie = specie
          end

        private

          # @return [SpeciePureUnitsFactory]
          def make_pure_factory
            SpeciePureUnitsFactory.new(dict)
          end

          # @param [Units::SpecieContextProvider] context
          # @return [SpecieContextUnitsFactory]
          def make_context_factory(context)
            SpecieContextUnitsFactory.new(dict, pure_factory, context)
          end

          # @param [Array] ordered_graph
          # @return [Units::SpecieContextProvider]
          def make_context_provider(ordered_graph)
            Units::SpecieContextProvider.new(dict, nodes_graph, ordered_graph)
          end

          # @oaram [SpecieContextUnitsFactory] factory
          # @return [Units::SpecieCreationUnit]
          def make_creator_unit(factory)
            factory.creator(@specie)
          end

          # @param [Units::ContextSpecieUnit] source_unit
          # @return [Array]
          def init_procs(source_unit)
            [check_atoms_proc(source_unit)]
          end

          # @param [Units::ContextSpecieUnit] unit
          # @return [Proc]
          def check_atoms_proc(source_unit)
            -> &block { source_unit.check_existence(&block) }
          end
        end

      end
    end
  end
end
