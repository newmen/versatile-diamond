module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction check laterals algorithm
        class ReactionCheckLateralsBuilder < LateralChunksAlgorithmBuilder

          # Inits builder
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          # @param [Specie] target_specie from which the algorithm will be built
          def initialize(generator, lateral_chunks, target_specie)
            @target_specie = target_specie
            super(generator, lateral_chunks)
          end

        private

          attr_reader :target_specie

          # Creates backbone of algorithm
          # @return [CheckLateralsBackbone] the backbone which provides ordered graph
          def create_backbone
            CheckLateralsBackbone.new(generator, lateral_chunks, target_specie)
          end

          # Creates factory of units for algorithm generation
          # @return [CheckLateralsUnitsFactory] correspond units factory
          def create_factory
            CheckLateralsUnitsFactory.new(generator, lateral_chunks)
          end

          # Gets an unit from which the search begins
          # @return [BaseUnit] the unit by which entry variables will be initialized
          def initial_unit
            main_nodes = backbone.entry_nodes.flatten.uniq
            factory.make_unit(main_nodes)
          end

          # Gets the list of chunk reactions which will created for concretization of
          # lateral reactions
          #
          # @return [Array] the list of checking chunk reactions
          def target_reactions
            lateral_chunks.root_affixes_for(target_specie)
          end

          # Builds checking bodies for all lateral reactions
          # @return [String] the string with cpp code
          def body
            target_reactions.map(&method(:body_for)).join
          end

          # Builds body of algorithm for passed reaction
          # @param [LateralReaction] reaction to which the target reaction will
          #   concretized
          # @return [String] the string with cpp code
          def body_for(reaction)
            backbone.entry_nodes.reduce('') do |acc, nodes|
              acc + combine_algorithm(reaction, nodes)
            end
          end

          # Build check laterals algorithm by combining procs that occured by walking
          # on backbone graph ordered from nodes
          #
          # @param [LateralReaction] reaction to which the target reaction will
          #   concretized
          # @param [Array] nodes from which walking will occure
          # @return [String] the cpp code find algorithm
          def combine_algorithm(reaction, nodes)
            nodes_rl_sidepieces(reaction, nodes).reduce('') do |acc, nbrs_with_species|
              acc + check_reaction(reaction, nbrs_with_species)
            end
          end

          # Gets the code which checks one chunk reaction
          # @param [LateralReaction] reaction which will be checked
          # @param [Array] nbrs_with_species the list: relation proc args with
          #   sidepiece species which are part of checking reaction
          # @return [String] the string with cpp code
          def check_reaction(reaction, nbrs_with_species)
            sidepieces = nbrs_with_species.last.uniq(&:original)
            uniq_target = nbrs_with_species.first.first.first.uniq_specie
            creator_unit = factory.creator(reaction, uniq_target, sidepieces)
            check_sidepieces([nbrs_with_species]) { creator_unit.lines }
          end

          # Gets the list of tuples with neighbour nodes, parameter of relation between
          # them and near sidepiece species
          #
          # @param [LateralReaction] reaction which will be used for detect that
          #   relation between nodes take a place
          # @param [Array] nodes from which the neighbour nodes and relation parameter
          #   will be gotten
          # @return [Array] the list of tuples with nodes, relation parameter and
          #   sidepiece species
          def nodes_rl_sidepieces(reaction, nodes)
            checking_rels(nodes).each_with_object([]) do |(nbrs, rel_params), acc|
              if reaction.use_relation?(rel_params)
                species = other_side_species(nbrs)
                acc << [[nodes, nbrs, rel_params], species]
              end
            end
          end

          # Wraps unique specie from each node
          # @param [Array] nodes from which the unique species will be gotten
          # @return [Array] the list of wrapped unique species
          def other_side_species(nodes)
            nodes.map { |node| OtherSideSpecie.new(node.uniq_specie) }
          end
        end

      end
    end
  end
end
