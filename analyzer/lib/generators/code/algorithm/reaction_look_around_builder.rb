module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction look around algorithm
        class ReactionLookAroundBuilder < BaseAlgorithmBuilder

          # Inits builder by main engine code generator and lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(generator, lateral_chunks)
            @lateral_chunks = lateral_chunks
            super(generator)
          end

          # Generates find algorithm cpp code for target reaction
          # @return [String] the string with cpp code of find reaction algorithm
          def build
            main_nodes = backbone.entry_nodes.flatten.uniq
            unit = factory.make_unit(main_nodes)
            unit.first_assign!

            unit.define_target_atoms_line +
              backbone.entry_nodes.reduce('') do |acc, nodes|
                acc + combine_algorithm(nodes)
              end
          end

        private

          # Creates backbone of algorithm
          # @return [SpecieBackbone] the backbone which provides ordered graph
          def create_backbone
            LateralChunksBackbone.new(generator, @lateral_chunks)
          end

          # Creates factory of units for algorithm generation
          # @return [LateralChunksUnitsFactory] correspond units factory
          def create_factory
            LateralChunksUnitsFactory.new(generator, @lateral_chunks)
          end

          # Build look around algorithm by combining procs that occured by walking on
          # backbone graph ordered from nodes
          #
          # @param [Array] nodes from which walking will occure
          # @return [String] the cpp code find algorithm
          def combine_algorithm(nodes)
            collect_parts(nodes).reduce(:+)
          end

          # @return [Array] the array of cpp code strings
          def collect_parts(nodes)
            _, rels = ordered_graph_from(nodes).first
            rels.map do |nbrs, rel_params|
              func = relations_proc(nodes, nbrs, rel_params)
              func.call { creation_lines(nbrs) }
            end
          end

          # Gets the lines by which the lateral reaction will be created in algorithm
          # @return [String] the cpp code string with lateral reaction creation
          def creation_lines(tail_nodes)
            detect_sidepieces(tail_nodes).reduce('') do |acc, (reaction, species)|
              acc + factory.creator(reaction, species).lines('chunks[index++]')
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
              [@lateral_chunks.select_reaction(node.spec_atom), node.uniq_specie]
            end
          end
        end

      end
    end
  end
end
