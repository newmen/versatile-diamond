module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Represents node which is used in lateral reaction alrogithms builders
        # @abstract
        class LateralNode < Tools::TransparentProxy

          # @param [LateralChunks] lateral_chunks
          # @param [ReactantNode] reactant_node
          def initialize(lateral_chunks, reactant_node)
            super(reactant_node)
            @lateral_chunks = lateral_chunks

            @_lateral_reaction = nil
          end

          # @return [LateralReaction] the single lateral reaction
          def lateral_reaction
            @_lateral_reaction ||= @lateral_chunks.select_reaction(spec_atom)
          end

          # Default value
          # @return [Boolean]
          def side?
            false
          end
        end

      end
    end
  end
end
