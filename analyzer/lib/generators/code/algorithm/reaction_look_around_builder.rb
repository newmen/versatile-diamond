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

          # Builds body of algorithm
          # @return [String] the string with cpp code
          def body
            backbone.entry_nodes.reduce('') do |acc, nodes|
              acc + combine_algorithm(nodes)
            end
          end

          # Build look around algorithm by combining procs that occured by walking
          # on backbone graph ordered from nodes
          #
          # @param [Array] nodes from which walking will occure
          # @return [String] the cpp code find algorithm
          def combine_algorithm(nodes)
            checking_rels(nodes).reduce('') do |acc, (nbrs, rel_params)|
              func = relations_proc(nodes, nbrs, rel_params)
              acc + func.call { creation_lines(nbrs) }
            end
          end

          # Gets the lines by which the lateral reaction will be created in algorithm
          # @param [Array] side_nodes the list of nodes from which the lateral reaction
          #   will be created
          # @return [String] the cpp code string with lateral reaction creation
          def creation_lines(side_nodes)
            detect_sidepieces(side_nodes).reduce('') do |acc, (reaction, species)|
              acc + factory.creator(reaction, species).lines
            end
          end

          # Gets the instances of lateral reaction and sidepiece species which
          # available on ordered graph from passed nodes
          #
          # @param [Array] nodes from which around iteration begining
          def detect_sidepieces(nodes)
            groups = reactions_with_species(nodes).group_by(&:first)
            groups.map { |reaction, pairs| [reaction, pairs.map(&:last)] }
          end

          # Gets the list of pairs of lateral reaction and specie which uses in it
          # @param [Array] nodes by which the reaction will detected
          # @return [Array] the list of reation-specie pairs
          def reactions_with_species(nodes)
            nodes.map do |node|
              [lateral_chunks.select_reaction(node.spec_atom), node.uniq_specie]
            end
          end
        end

      end
    end
  end
end
