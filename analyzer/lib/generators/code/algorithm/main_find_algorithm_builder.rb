module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain base logic for building find algorithms
        # @abstract
        class MainFindAlgorithmBuilder < BaseFindAlgorithmBuilder
        private

          # Build find algorithm by combining procs that occured by walking on backbone
          # ordered graph from nodes
          #
          # @param [Array] nodes from which walking will occure
          # @return [Expressions::Core::Statement]
          def combine_algorithm(nodes)
            ordered_graph = backbone.ordered_graph_from(nodes)
            context = specie_context(ordered_graph)
            factory = context_factory(context)
            procs = collect_procs(factory, ordered_graph, init_procs(factory, nodes))
            call_procs(procs) { creator(context).create }
          end

          # Accumulates relations procs from passed unit
          # @param [Units::BaseContextUnit] unit from which the relations will be
          #   collected
          # @param [Array] nbrs the neighbour units
          # @return [Array] the array of collected relations procs
          def accumulate_relations(unit, nbrs)
            nbrs.map { |nbr| relations_proc(unit, nbr) }
          end
        end

      end
    end
  end
end
