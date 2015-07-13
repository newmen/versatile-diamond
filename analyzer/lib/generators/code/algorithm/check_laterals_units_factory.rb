module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction check laterals algorithm units
        class CheckLateralsUnitsFactory < LateralChunksUnitsFactory

          # Gets the lateral chunk creator unit
          # @param [LateralReaction] lateral_reaction to which will concretized finding
          #   reaction
          # @param [Array] side_nodes the list of nodes from which the lateral reaction
          #   will be created
          # @param [Array] target_nodes the list of nodes in which the reaction will
          #   be checked
          # @return [ReactionCreatorUnit] the unit for defines lateral chunk creation
          #   code block
          def creator(lateral_reaction, side_nodes, target_nodes)
            ReactionCheckLateralsCreatorUnit.new(
              namer,
              lateral_reaction,
              lateral_chunks,
              species_with_atoms_of(side_nodes),
              species_with_atoms_of(target_nodes))
          end

        private

          # Collects unique species and atoms from passed nodes
          # @param [Array] nodes from which unique species will be gotten
          # @return [Array] the list of unique species with atoms
          def species_with_atoms_of(nodes)
            nodes.map { |node| [node.uniq_specie, node.atom] }
          end
        end

      end
    end
  end
end
