module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain base logic for building find algorithms
        # @abstract
        class BaseFindBuilder < BaseAlgorithmBuilder
        private

          # Gets the lines by which the finding instance will be created in algorithm
          # @return [String] the cpp code string with finding instance creation
          def creation_lines
            factory.creator.lines
          end

          # Build find algorithm by combining procs that occured by walking on backbone
          # ordered graph from nodes
          #
          # @param [Array] nodes from which walking will occure
          # @return [String] the cpp code find algorithm
          def combine_algorithm(nodes)
            reduce_procs(collect_procs(nodes)) { creation_lines }.call
          end

          # Accumulates relations procs from passed nodes
          # @param [Array] nodes from which the relations will be collected
          # @param [Array] rels the iterable relations
          # @return [Array] the array of collected relations procs
          def accumulate_relations(nodes, rels)
            rels.reduce([]) do |acc, (nbrs, rel_params)|
              acc << relations_proc(nodes, nbrs, rel_params)
            end
          end
        end

      end
    end
  end
end
