module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Contain logic for building find specie algorithm
        class SpecieFindBuilder < BaseBuilder

          # Inits builder by target specie and main engine code generator
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie the target specie code generator
          def initialize(generator, specie)
            super(generator)
            @specie = specie
            @backbone = SpecieBackbone.new(generator, specie)
            @factory = SpecieUnitsFactory.new(generator, specie)
          end

          # Generates cpp code by which target specie will be found when simulation doing
          # @return [String] the string with cpp code of find specie algorithm
          def build
            entry_nodes_with_elses.reduce('') do |acc, (nodes, else_prefix)|
              @factory.reset!
              acc + body_for(nodes, else_prefix)
            end
          end

        private

          # Gets entry nodes zipped with else prefixes for many ways condition
          # @return [Array] entry nodes zipped with else prefixes
          def entry_nodes_with_elses
            entry_nodes = EntryNodes.new(@backbone).list
            elses = [''] + ['else '] * (entry_nodes.size - 1)
            entry_nodes.zip(elses)
          end

          # @return [String]
          def body_for(nodes, else_prefix)
            unit = @factory.make_unit(nodes)
            unit.first_assign!

            unit.check_existence(else_prefix) do
              combine_algorithm(nodes) { @factory.creator.lines }
            end
          end

          # Build find algorithm by combining procs that occured by walking on backbone
          # graph from nodes
          #
          # @param [Array] nodes from which walking will occure
          # @yield should return cpp code string
          # @return [String] the cpp code find algorithm
          def combine_algorithm(nodes, &block)
            reduce_procs(collect_procs(nodes), &block).call
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] nodes by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(nodes)
            ordered_graph = @backbone.ordered_graph_from(nodes)
            ordered_graph.each_with_object([]) do |(ns, rels), acc|
              acc << species_proc(ns)
              rels.each do |nbrs, rel_params|
                acc << relations_proc(ns, nbrs, rel_params)
              end
            end
          end

          # Wraps calling of checking relations between units generation to lambda
          # @param [Array] nodes from which relations will be checked
          # @param [Array] nbrs the neighbour nodes to which relations will be checked
          # @return [Proc] lazy calling for check relations unit method
          def relations_proc(nodes, nbrs, rel_params)
            curr_unit = @factory.make_unit(nodes)
            nbrs_unit = @factory.make_unit(nbrs)
            -> &block { curr_unit.check_relations(nbrs_unit, rel_params, &block) }
          end

          # @return [Array] the list of all collected procs
          def species_proc(nodes)
            unit = @factory.make_unit(nodes)
            -> &block { unit.check_species(&block) }
          end
        end

      end
    end
  end
end
