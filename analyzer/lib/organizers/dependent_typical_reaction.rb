module VersatileDiamond
  module Organizers

    # Wraps structural reaction without lateral interactions
    class DependentTypicalReaction < DependentSpecReaction

      def_delegator :reaction, :complex_source_spec_and_atom

      # Selects complex source spec and them changed atom
      # @return [SpecificSpec] the covered spec
      def source_covered_by(termination_spec)
        spec, atom = reaction.complex_source_spec_and_atom
        termination_spec.cover?(spec, atom) ? spec : nil
      end

      # Typical reaction isn't lateral
      # @return [Boolean] false
      def lateral?
        false
      end

      # Organize dependencies from another lateral reactions
      # @param [Array] lateral_reactions the possible children
      def organize_dependencies!(lateral_reactions)
        laterals = lateral_reactions.select do |possible|
          reaction.same_positions?(possible.reaction)
        end

        chunks = laterals.map(&:chunk)
        organize_chunks!(chunks)
        organize_lateral_children!(chunks)
      end

      # Collects chunks of all children lateral reactions, builds by them new possible
      # lateral reactions and organize dependencies between them. Builded lateral
      # reactions returns from method for to add them to list of lateral reactions in
      # analysis result
      #
      # @return [Array] the list of builded lateral reactions
      def combine_laterals!


      end

    private

      # Organizes dependencies between chunks by dynamic programming table
      # @param [Array] chunks the list of chunks each item of which will be organized
      def organize_chunks!(chunks)
        table = ChunksTable.new(chunks)
        chunks.each do |chunk|
          table.best(chunk).parents.each do |parent|
            chunk.store_parent(parent)
          end
        end
      end

      # Organizes dependencies between children lateral reactions which gets through
      # passed chunks
      #
      # @param [Array] chunks by which the children will be organized
      def organize_lateral_children!(chunks)
        chunks.each do |chunk|
          if chunk.parents.empty?
            chunk.lateral_reaction.store_parent(self)
          else
            chunk.parents.each do |pr|
              chunk.lateral_reaction.store_parent(pr.lateral_reaction)
            end
          end
        end
      end
    end

  end
end
