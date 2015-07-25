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
          # @param [Specie] specie from which the algorithm will be builded
          def initialize(generator, lateral_chunks, specie)
            @specie = specie
            super(generator, lateral_chunks)
          end

        private

          # Creates backbone of algorithm
          # @return [CheckLateralsBackbone] the backbone which provides ordered graph
          def create_backbone
            CheckLateralsBackbone.new(generator, lateral_chunks, @specie)
          end

          # Creates factory of units for algorithm generation
          # @return [CheckLateralsUnitsFactory] correspond units factory
          def create_factory
            CheckLateralsUnitsFactory.new(generator, lateral_chunks)
          end

          # Builds checking bodies for all lateral reactions
          # @return [String] the string with cpp code
          def body
            lateral_chunks.root_affixes_for(@specie).reduce('') do |acc, reaction|
              acc + body_for(reaction)
            end
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
            checking_rels(nodes).reduce('') do |acc, (nbrs, rel_params)|
              func = relations_proc(nodes, nbrs, rel_params)
              acc + func.call { creation_lines(reaction, nodes, nbrs) }
            end
          end

          # Gets the lines by which the lateral reaction will concretized in algorithm
          # @param [LateralReaction] reaction to which the target reaction will
          #   concretized
          # @param [Array] side_nodes the list of nodes from which the lateral reaction
          #   will be created
          # @param [Array] target_nodes the list of nodes in which the reaction will
          #   be checked
          # @return [String] the cpp code string with lateral reaction concretization
          def creation_lines(reaction, side_nodes, target_nodes)
            factory.creator(reaction, side_nodes, target_nodes).lines
          end
        end

      end
    end
  end
end
