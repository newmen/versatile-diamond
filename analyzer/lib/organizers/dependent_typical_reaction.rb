module VersatileDiamond
  module Organizers

    # Wraps structural reaction without lateral interactions
    class DependentTypicalReaction < DependentSpecReaction

      def_delegators :reaction, :complex_source_spec_and_atom, :full_mapping

      # Selects complex source spec and them changed atom
      # @return [SpecificSpec] the covered spec
      def source_covered_by(termination_spec)
        spec, atom = reaction.complex_source_spec_and_atom
        termination_spec.cover?(spec, atom) ? spec : nil
      end

      # Organize dependencies from another lateral reactions
      # @param [Array] lateral_reactions the possible children
      def organize_dependencies!(lateral_reactions)
        # TODO: excess checking because concept reaction already have a list of
        # children reactions
        lateral_reactions.each do |possible|
          poss_conc = possible.reaction
          if reaction.same_specs?(poss_conc) && reaction.same_positions?(poss_conc)
            possible.store_parent(self)
          end
        end
      end

      # Combines all chunks from children lateral reactions and find unresolved lateral
      # reactions
      #
      # @return [Array] the list of unresolved lateral reactions
      def combine_children_laterals!
        combiner = ChunksCombiner.new(self)
        combiner.combine(children.map(&:chunk))
      end
    end

  end
end
