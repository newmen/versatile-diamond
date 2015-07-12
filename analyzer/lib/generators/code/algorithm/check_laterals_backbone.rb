module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the check laterals algorithm will be builded
        class CheckLateralsBackbone < LateralChunksBackbone

          # Initializes backbone by lateral chunks object and target sidepiece specie
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks by which graph will be builded
          # @param [Specie] specie from which graph will be builded
          def initialize(generator, lateral_chunks, specie)
            super(generator, lateral_chunks)
            @specie = specie
          end

        private

          # Makes clean graph with relations only from target nodes
          # @return [Hash] the grouped graph with relations only from target nodes
          def make_final_graph
            grouped_graph.each_with_object({}) do |(nodes, rels), acc|
              target_nodes = filter_nodes(nodes)
              unless target_nodes.empty?
                nbr_sas = select_nbrs(nodes)
                acc[target_nodes] = rels.map do |ns, r|
                  [ns.select { |n| nbr_sas.include?(n.spec_atom) }, r]
                end
              end
            end
          end

          # Selects from passed nodes only nodes which contains target specie
          # @param [Array] nodes which will be filtered
          # @return [Array] the list of nodes with target specie
          def filter_nodes(nodes)
            nodes.select { |node| node.uniq_specie.original == @specie }
          end

          # Selects neighbour spec-atoms from original lateral chunks links graph which
          # correspond to passed nodes
          #
          # @param [Array] nodes for which the neghbours will be selected
          # @return [Array] the list of neighbour spec-atoms
          def select_nbrs(nodes)
            lateral_chunks.links.reduce([]) do |acc, (spec_atom, rels)|
              if nodes.any? { |node| node.spec_atom == spec_atom }
                acc + rels.map(&:first)
              else
                acc
              end
            end
          end
        end

      end
    end
  end
end
