module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building find reaction algorithm
        class ReactionFindBuilder < MainFindAlgorithmBuilder

          # Inits builder by main engine code generator, target reaction and reatant
          # specie which should be found by generating algorithm
          #
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          # @param [Specie] specie the reactant from which the algorithm will be built
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
          # @return [ReactionBackbone] the backbone which provides ordered graph
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
            relations_checks(ordered_graph) + compliences_checks(ordered_graph)
          end

          # Collects all checks of relations
          # @param [Array] ordered_graph from which the relations will be checked
          # @return [Array] the array of procs which will check the relations
          def relations_checks(ordered_graph)
            ordered_graph.flat_map { |ns, rels| accumulate_relations(ns, rels) }
          end

          # Collects compliences checks
          # @param [Array] ordered_graph which atoms compliences will be checked
          # @return [Array] the list of procs which will check the compliences
          def compliences_checks(ordered_graph)
            not_compiences(ordered_graph).map do |nodes_with_rels|
              unit = factory.make_unit(nodes_with_rels.map(&:first))
              atoms_to_rels = atoms_to_rels_from(nodes_with_rels)
              -> &prc { unit.check_compliances(atoms_to_rels, &prc) }
            end
          end

          # Makes mirror of nodes atoms to relations
          # @param [Array] nodes_with_rels which will be transformed to atoms-rels hash
          # @return [Hash] the mirror of atoms to relations
          def atoms_to_rels_from(nodes_with_rels)
            Hash[nodes_with_rels.map { |node, rel| [node.atom, rel] }]
          end

          # Finds non complianced nodes
          # @param [Array] ordered_graph by which the nodes will be found
          # @return [Array] the list of lists of nodes pairs with relations or nil
          def not_compiences(ordered_graph)
            ordered_graph.flat_map(&method(:collect_not_compliences)).uniq
          end

          # Collects all neighbour nodes with non existing relations
          # @param [Array] nodes from which the relations will be checked
          # @param [Array] rels list the relations from which will be checked
          # @return [Array] the list of nodes which relations which must be checked
          def collect_not_compliences(nodes, rels)
            rels.map { |nbrs, _| nbrs_with_rels(nodes, nbrs) }.compact
          end

          # Gets list of pairs of node which relation where one of relation must not be
          # exists
          #
          # @param [Array] nodes from which the relations will be checked
          # @param [Array] nbrs to which the relations will be checked
          # @return [Array] the list of triples or false
          def nbrs_with_rels(nodes, nbrs)
            relations = relations_between(merge_nodes(nodes, nbrs))
            !relations.all?(&:exist?) && nbrs.zip(relations)
          end

          # Merges the passed nodes
          # @param [Array] nodes which will be a first item of each pair
          # @param [Array] nbrs which will be a second item of each pair
          # @return [Array] the list of nodes pairs
          def merge_nodes(nodes, nbrs)
            if nodes.size == nbrs.size
              nodes.zip(nbrs)
            elsif nodes.size == 1
              nodes.cycle.zip(nbrs)
            elsif nbrs.size == 1
              nodes.zip(nbrs.cycle)
            else
              raise ArgumentError, 'Cannot merge nodes with so different sizes'
            end
          end

          # Collects relations between each pair of nodes
          # @param [Array] pairs the list of nodes
          # @return [Array] the list of relations between
          def relations_between(pairs)
            pairs.map do |pair|
              @reaction.relation_between(*pair.map(&method(:spec_atom_from)))
            end
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
