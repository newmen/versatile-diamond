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
          # @return [String] the cpp code find algorithm
          def combine_algorithm(nodes)
            call_procs(collect_procs(nodes)) { creation_lines }
          end

          # Accumulates relations procs from passed unit
          # @param [BaseUnitsFactory] factory for neighbour units
          # @param [Units::BaseUnit] unit from which the relations will be collected
          # @param [Array] rels the iterable relations
          # @return [Array] the array of collected relations procs
          def accumulate_relations(factory, unit, rels)
            rels.map do |nbr_nodes, rel_params|
              nbrs_unit = factory.make_unit(nbr_nodes)
              relations_proc(unit, nbrs_unit, rel_params)
            end
          end
        end

      end
    end
  end
end
