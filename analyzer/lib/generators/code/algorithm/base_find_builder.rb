module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain base logic for building find algorithms
        # @abstract
        class BaseFindBuilder
          include Modules::ProcsReducer

          # Inits builder by main engine code generator
          # @param [EngineCode] generator the major engine code generator
          def initialize(generator)
            @generator = generator
            @backbone = create_backbone
            @factory = create_factory
          end

        private

          attr_reader :generator, :backbone, :factory

          # Gets the lines by which the specie will be created in algorithm
          # @return [String] the cpp code string with specie creation
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
