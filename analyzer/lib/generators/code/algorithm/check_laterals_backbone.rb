module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the check laterals algorithm will be built
        class CheckLateralsBackbone < LateralChunksBackbone
          include Modules::ListsComparer
          include Mcs::SpecsAtomsComparator

          # Initializes backbone by lateral chunks object and target sidepiece specie
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks by which graph will be built
          # @param [Specie] specie from which graph will be built
          def initialize(generator, lateral_chunks, specie)
            super(generator, lateral_chunks)
            @specie = specie
          end

          # @return [Array]
          def action_nodes
            entry_nodes.reduce(:+).uniq
          end

        private

          # Detects same key nodes in passed graph
          # @param [Hash] graph where key nodes will be checked
          # @param [Array] nodes which analogies will checked in final graph
          # @return [Array] found key nodes or passed nodes list
          def detect_key_nodes(graph, nodes)
            keys = graph_with_same_nodes(graph, nodes).keys
            if keys.size > 1
              raise 'Not only one similar key available'
            else
              keys.first || nodes
            end
          end

          # Selects a part of passed graph which use same nodes as was passed
          # @param [Hash] graph which will filtered
          # @param [Array] nodes which analogies will checked in passed graph
          # @return [Hash] the graph in which forward directed relations are all
          #   outcomes from nodes which are similar as passed
          def graph_with_same_nodes(graph, nodes)
            graph.select do |ns, _|
              ns != nodes && !identical_specs?(ns, nodes) && same_nodes?(ns, nodes)
            end
          end

          # Checks that passed nodes lists are identical
          # @param [Array] nodes_lists with two comparing arguments
          # @return [Boolean] are passed lists identical or not
          def same_nodes?(*nodes_lists)
            lists_are_identical?(*nodes_lists) do |n1, n2|
              same_sa?(n1.spec_atom, n2.spec_atom)
            end
          end

          # Checks that both passed lists contains equal proxy dependent species
          # @param [Array] nodes_lists with two comparing arguments
          # @return [Boolean] are dependent species in passed lists identical or not
          def identical_specs?(*nodes_lists)
            lists_are_identical?(*nodes_lists.map { |nodes| nodes.map(&:spec).uniq })
          end

          # Makes clean graph with relations only from target nodes
          # @return [Hash] the grouped graph with relations only from target nodes
          def make_final_graph
            grouped_graph.each_with_object({}) do |(nodes, rels), acc|
              target_nodes = filter_nodes(nodes)
              unless target_nodes.empty?
                nbr_sas = select_nbrs(nodes)
                key_nodes = detect_key_nodes(acc, target_nodes)
                acc[key_nodes] ||= []
                acc[key_nodes] += rels.map do |ns, r|
                  [ns.select { |n| nbr_sas.include?(n.spec_atom) }, r]
                end
              end
            end
          end

          # Selects from passed nodes only nodes which contains target specie
          # @param [Array] nodes which will be filtered
          # @return [Array] the list of nodes with target specie
          def filter_nodes(nodes)
            nodes.select do |node|
              node.uniq_specie.original == @specie &&
                lateral_chunks.sidepiece_spec?(node.spec.spec)
            end
          end

          # Selects neighbour spec-atoms from original lateral chunks links graph which
          # correspond to passed nodes
          #
          # @param [Array] nodes for which the neghbours will be selected
          # @return [Array] the list of neighbour spec-atoms
          def select_nbrs(nodes)
            lateral_chunks.links.reduce([]) do |acc, (spec_atom, rels)|
              next acc unless nodes.any? { |node| node.spec_atom == spec_atom }
              acc + rels.map(&:first)
            end
          end

          # @return [Array]
          def grouped_keys
            final_graph.keys.groups(&method(:reactions_set_from))
          end

          # @param [Array] nodes
          # @return
          def grouped_slices(nodes)
            slices_with(nodes).groups { |key, _| reactions_set_from(key) }
          end

          # @param [Array] nodes
          # @return [Set]
          def reactions_set_from(nodes)
            nodes.map(&method(:reaction_with)).to_set
          end
        end

      end
    end
  end
end
