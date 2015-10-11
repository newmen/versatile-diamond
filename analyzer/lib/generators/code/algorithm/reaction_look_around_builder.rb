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
          # @return [BaseUnit] the unit by which entry variables will be initialized
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

          # Builds body of algorithm
          # @return [String] the string with cpp code
          def body
            pts = ordered_entry_nodes.flat_map(&method(:reaction_with_rl_sidepieces))
            slices = split_by_first(pts)
            slices.map { |args| check_reaction(*args) }.join
          end

          # Gets the code which checks one chunk reaction
          # @param [TypicalReaction] reaction which will be checked
          # @param [Array] nbrs_with_species the list of lists of relation proc args
          #   with sidepiece which are part of checking reaction
          # @return [String] the string with cpp code
          def check_reaction(reaction, nbrs_with_species)
            uniq_sidepieces = nbrs_with_species.map(&:last).reduce(:+).uniq(&:original)
            creator_unit = factory.creator(reaction, uniq_sidepieces)
            species_checks_procs = nbrs_with_species.map { |as| check_sidepiece(*as) }
            reduce_procs(species_checks_procs) { creator_unit.lines }.call
          end

          # Gets the proc which checks neighbour sidepiece, it relations and species
          # @param [Array] rel_args the arguments for #relation_proc method
          # @param [Array] sidepieces which will be checked after relations
          # @return [Proc] which generates cpp code for check the sidepiece
          def check_sidepiece(rel_args, sidepieces)
            rl_proc = relations_proc(*rel_args)
            checker_unit = factory.checker(sidepieces)
            -> &block do
              rl_proc.call { checker_unit.define_and_check(&block) }
            end
          end

          # Splits the list of pairs to hash where keys are identical first items and
          # the values are lists of grouped second items
          #
          # @param [Array] pairs which will be splited
          # @return [Array] the grouping result
          def split_by_first(pairs)
            pairs.group_by(&:first).map { |first, pairs| [first, pairs.map(&:last)] }
          end

          # Gets the instances of lateral reaction and relation proc arguments with
          # sidepiece species which available on ordered graph from passed nodes
          #
          # @param [Array] the pair where first is lateral reaction and the second is
          #   the list of two items where the first is relation proc arguments and the
          #   second is sidepiece species which are additional reactants
          def reaction_with_rl_sidepieces(nodes)
            checking_rels(nodes).map do |nbrs, rel_params|
              result = split_by_first(reactions_with_species(nbrs))
              if result.size > 1
                fail "Can't process nodes with different lateral chunks and species"
              end

              reaction, species = result.first
              [reaction, [[nodes, nbrs, rel_params], species]]
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
              OtherSideSpecie.new(node.uniq_specie)
            ]
          end
        end

      end
    end
  end
end
