module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the check laterals algorithm will be built
        class CheckLateralsBackbone < LateralChunksBackbone

          # Initializes backbone by lateral chunks object and target sidepiece specie
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks by which graph will be built
          # @param [Specie] specie from which graph will be built
          def initialize(generator, lateral_chunks, specie)
            super(generator, lateral_chunks)
            @specie = specie
          end

        private

          # @param [Array] nodes
          # @return [Boolean]
          # @override
          def final_key?(nodes)
            super && nodes.all? { |n| n.uniq_specie.original == @specie }
          end

          # @return [Symbol] name of predicate function
          def target_predicate_name
            :sidepiece_spec?
          end

          # Gets list of spec-atom pairs from which the action nodes will be mapped
          # @return [Array] the list of sidepiece spec-atom pairs
          def action_keys
            spec_name = @specie.spec.name
            keys = lateral_chunks.side_keys.select { |s, _| s.name == spec_name }
            keys.uniq do |spec, atom|
              [spec.name, @specie.spec.spec.atom(spec.keyname(atom))]
            end
          end

          # @param [ReactantNode] node
          # @return [SidepieceNode]
          def target_node(node)
            lateral_nodes_factory.sidepiece_node(node)
          end

          # @param [Array] key_with_rels
          # @return [Array]
          def key_group_by_slice(key_with_rels)
            key, rels = key_with_rels
            [reactions_set_from(key), rels.map(&:first).to_set]
          end

          # @param [Array] ordered_graph
          # @return [Array]
          def group_by_reactions(ordered_graph)
            ordered_graph.groups { |key, _| reactions_set_from(key) }
          end

          # @param [Array] nodes
          # @return [Set]
          def reactions_set_from(nodes)
            nodes.map(&:lateral_reaction).to_set
          end
        end

      end
    end
  end
end
