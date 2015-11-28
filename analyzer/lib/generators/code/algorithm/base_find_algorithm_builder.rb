module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain base logic for building find algorithms
        # @abstract
        class BaseFindAlgorithmBuilder
          include Modules::ProcsReducer
          extend Forwardable

          # Inits builder by main engine code generator
          # @param [EngineCode] generator the major engine code generator
          def initialize(generator)
            @generator = generator
            @backbone = create_backbone
            @factory = create_factory
          end

        private

          attr_reader :generator, :backbone, :factory
          def_delegator :backbone, :ordered_graph_from

          # Wraps calling of checking relations between generation units to lambda
          # @param [Array] nodes from which relations will be checked
          # @param [Array] nbrs the neighbour nodes to which relations will be checked
          # @return [Proc] lazy calling for check relations unit method
          def relations_proc(nodes, nbrs, rel_params)
            curr_unit = factory.make_unit(nodes)
            nbrs_unit = factory.make_unit(nbrs)
            -> &block { curr_unit.check_relations(nbrs_unit, rel_params, &block) }
          end
        end

      end
    end
  end
end
