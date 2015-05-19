module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building find reaction algorithm
        class ReactionFindBuilder < BaseFindBuilder

          # Inits builder by main engine code generator, target reaction and reatant
          # specie which should be found by generating algorithm
          #
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          # @param [Specie] specie the reactant which will be found by algorithm
          def initialize(generator, reaction, specie)
            @reaction = reaction
            @specie = specie
            super(generator)
          end

          # Generates find algorithm cpp code for target reaction
          # @return [String] the string with cpp code of find reaction algorithm
          def build
            nodes = backbone.entry_nodes.first
            unit = factory.make_unit(nodes)
            unit.first_assign!

            unit.check_symmetries do
              combine_algorithm(nodes)
            end
          end

        private

          # Creates backbone of algorithm
          # @return [SpecieBackbone] the backbone which provides ordered graph
          def create_backbone
            ReactionBackbone.new(generator, @reaction, @specie)
          end

          # Creates factory of units for algorithm generation
          # @return [ReactionUnitsFactory] correspond units factory
          def create_factory
            ReactionUnitsFactory.new(generator, @reaction)
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] nodes by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(nodes)
            ordered_graph = backbone.ordered_graph_from(nodes)
            result = ordered_graph.reduce([]) do |acc, (ns, rels)|
              acc + accumulate_relations(ns, rels)
            end

            pswrs = not_compiences(ordered_graph)
            if pswrs
              atoms_to_rels = Hash[pswrs.map { |pair, rel| [pair.last.atom, rel] }]
              unit = factory.make_unit(pswrs.map(&:first).transpose.last)
              result << -> &prc { unit.check_compliences(atoms_to_rels, &prc) }
            end
            result
          end

          # Finds non complienced nodes
          # @param [Array] ordered_graph by which the nodes will be found
          # @return [Array] the list of nodes pairs with relations or nil
          def not_compiences(ordered_graph)
            result = nil
            ordered_graph.reverse.each do |ns, rels|
              rels.each do |nbrs, _|
                next unless ns.size == nbrs.size # TODO: why reject?
                pswrs = ns.zip(nbrs).map do |pair|
                  rel = @reaction.relation_between(*pair.map(&method(:spec_atom_from)))
                  [pair, rel]
                end

                result = pswrs if pswrs.any? { |_, rel| !rel.exist? }
              end
              break if result
            end
            result
          end

          # Makes reaction links graph vertex from passed node
          # @param [ReactantNode] node from which the links vertex will be gotten
          # @return [Array] the reaction links graph vertex
          def spec_atom_from(node)
            [node.dept_spec.spec, node.atom]
          end
        end

      end
    end
  end
end
