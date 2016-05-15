module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction look around algorithm
        class ReactionLookAroundBuilder < LateralChunksAlgorithmBuilder
        private

          # Creates backbone of algorithm
          # @return [LookAroundBackbone] the backbone which provides ordered graph
          def create_backbone
            LookAroundBackbone.new(generator, lateral_chunks)
          end

          # Creates factory of units for algorithm generation
          # @return [LookAroundUnitsFactory] correspond units factory
          def create_factory
            LookAroundUnitsFactory.new(generator, lateral_chunks)
          end

          # Gets an unit from which the search begins
          # @return [BasePureUnit] the unit by which entry variables will be initialized
          def initial_unit
            factory.make_unit(backbone.action_nodes)
          end

          # Orders entry nodes for case when we must nest one check to another
          def ordered_entry_nodes
            backbone.entry_nodes.sort do |a, b|
              if a.size == b.size
                a.max <=> b.max # reversed by nodes default ordering
              else
                b.size <=> a.size
              end
            end
          end

          # Split the sceleton tuples of neighbour nodes, relations between them and
          # correspond sidepiece species by reaction where it used
          #
          # @param [Array] entry_nodes the list of nodes from which the algorithm
          #   builds
          # @return [Array] the list of grouped arguments for #check_reaction method
          def slices(entry_nodes)
            group_by_reaction(entry_nodes.flat_map(&method(:reaction_rl_sidepieces)))
          end

          # Builds body of algorithm
          # @return [String] the string with cpp code
          def body
            slices(ordered_entry_nodes).map { |args| check_reaction(*args) }.join
          end

          # Gets the code which checks one chunk reaction
          # @param [TypicalReaction] reaction which will be checked
          # @param [Array] nbrs_with_species the list of lists of relation proc args
          #   with sidepiece which are part of checking reaction
          # @return [String] the string with cpp code
          def check_reaction(reaction, nbrs_with_species)
            uniq_sidepieces = nbrs_with_species.flat_map(&:last).uniq(&:original)
            creator_unit = factory.creator(reaction, uniq_sidepieces)
            check_sidepieces(nbrs_with_species) { creator_unit.lines }
          end

          # Groups the list of pairs to list of similar collections
          # @param [Array] pairs which will be splited
          # @return [Array] the grouping result
          def group_by_reaction(pairs)
            pairs.group_by(&:first).map { |react, rwoss| [react, rwoss.map(&:last)] }
          end

          # Gets the instances of lateral reaction and relation proc arguments with
          # sidepiece species which available on ordered graph from passed nodes
          #
          # @param [Array] the pair where first is lateral reaction and the second is
          #   the list of two items where the first is relation proc arguments and the
          #   second is sidepiece species which are additional reactants
          def reaction_rl_sidepieces(nodes)
            checking_rels(nodes).map do |nbrs, rel_params|
              result = group_by_reaction(reactions_with_species(nbrs))
              if result.one?
                reaction, species = result.first
                [reaction, [[nodes, nbrs, rel_params], species]]
              else
                msg = "Can't process nodes with different lateral chunks"
                raise ArgumentError, msg
              end
            end
          end

          # Gets the list of pairs of lateral reaction and specie which uses in it
          # @param [Array] nodes by which the reaction will detected
          # @return [Array] the list of reation-specie pairs
          def reactions_with_species(nodes)
            nodes.map(&method(:make_reaction_specie_pair))
          end

          # Creates a pair of reaction with unique sidepiece
          # @param [ReactantNode] node by which the pair will be created
          # @return [Array] the array with two items
          def make_reaction_specie_pair(node)
            [
              lateral_chunks.select_reaction(node.spec_atom),
              Instances::OtherSideSpecie.new(node.uniq_specie)
            ]
          end
        end

      end
    end
  end
end
