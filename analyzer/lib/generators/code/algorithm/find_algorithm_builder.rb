module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain base logic for building find algorithms
        # @abstract
        class FindAlgorithmBuilder
          include Modules::ProcsReducer

          # @param [BaseBackbone] backbone
          def initialize(backbone)
            @backbone = backbone

            @_dict, @_pure_factory = nil
          end

          # Generates find algorithm cpp code
          # @return [String] the string with cpp code of find algorithm
          def build
            dict.checkpoint!
            total_body.shifted_code
          end

        private

          attr_reader :backbone

          # @return [Units::Expressions::VarsDictionary]
          def dict
            @_dict ||= make_dict
          end

          # Default dictionary
          # @return [Units::Expressions::VarsDictionary]
          def make_dict
            Units::Expressions::VarsDictionary.new
          end

          # @return [BasePureUnitsFactory]
          def pure_factory
            @_pure_factory ||= make_pure_factory
          end

          # Define by default
          # @return [Boolean]
          def define_each_entry_node?
            true
          end

          # @return [Hash]
          def nodes_graph
            backbone.big_graph
          end

          # @return [Expressions::Core::Statement]
          def total_body
            backbone.entry_nodes.map(&method(:body_for)).reduce(:+)
          end

          # Generates the body of code from passed nodes
          # @param [Array] nodes from which the code will be generated
          # @return [Expressions::Core::Statement]
          def body_for(nodes)
            dict.rollback!
            pure_factory.unit(nodes).define! if define_each_entry_node?
            combine_algorithm(nodes)
          end

          # Builds find algorithm by combining procs that occured by walking on
          # backbone ordered graph from nodes
          #
          # @param [Array] nodes from which walking will occure
          # @return [Expressions::Core::Statement]
          def combine_algorithm(nodes)
            ordered_graph = backbone.ordered_graph_from(nodes)
            context = make_context_provider(ordered_graph)
            factory = make_context_factory(context)
            source_unit = factory.unit(nodes)
            procs = collect_procs(factory, ordered_graph, init_procs(source_unit))
            call_procs(procs, &make_creator_unit(factory).public_method(:create))
          end

          # Collects procs of conditions for body of find algorithm
          # @param [SpecieContextUnitsFactory] factory
          # @param [Array] ordered_graph
          # @param [Array] initial_procs
          # @return [Array] the array of procs which will combined later
          def collect_procs(factory, ordered_graph, initial_procs)
            ordered_graph.reduce(initial_procs) do |acc, (ns, rels)|
              unit = factory.unit(ns)
              nbrs = nbrs_units(factory, rels)
              acc + [check_species_proc(unit)] + accumulate_relations(unit, nbrs)
            end
          end

          # @oaram [SpecieContextUnitsFactory] factory
          # @param [Array] rels
          # @return [Array]
          def nbrs_units(factory, rels)
            rels.map(&:first).map(&factory.public_method(:unit))
          end

          # Accumulates relations procs from passed unit
          # @param [Units::ContextBaseUnit] unit from which the relations will be
          #   collected
          # @param [Array] nbrs the neighbour units
          # @return [Array] the array of collected relations procs
          def accumulate_relations(unit, nbrs)
            nbrs.map { |nbr| relations_proc(unit, nbr) }
          end

          # @param [Units::ContextBaseUnit] source_unit
          # @return [Array]
          def init_procs(source_unit)
            [initial_check_proc(source_unit)]
          end

          # @param [Units::ContextBaseUnit] source_unit
          # @return [Proc]
          def initial_check_proc(source_unit)
            -> &block { source_unit.check_existence(&block) }
          end

          # @param [Units::ContextBaseUnit] unit
          # @return [Proc] lazy calling for check species unit method
          def check_species_proc(unit)
            -> &block { unit.check_avail_species(&block) }
          end

          # Wraps calling of checking relations between generation units to lambda
          # @param [Units::ContextBaseUnit] unit from which relations will be checked
          # @param [Units::ContextBaseUnit] nbr to which relations will be checked
          # @return [Proc] lazy calling for check relations unit method
          def relations_proc(unit, nbr)
            -> &block { unit.check_relations_with(nbr, &block) }
          end
        end

      end
    end
  end
end
