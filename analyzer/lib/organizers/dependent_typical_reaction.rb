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
        lateral_reactions.each do |possible|
          lateral.store_parent(self) if reaction.same_positions?(possible.reaction)
        end
      end

      # Combines all chunks from children lateral reactions and find unresolved lateral
      # reactions
      #
      # @return [Array] the list of unresolved lateral reactions
      def combine_children_laterals!
        chunks = children.map(&:chunk)
        all_chunks = organize_chunks!(chunks)

        combine_laterals(all_chunks)
      end

    private

      # Builds by passed chunks new possible lateral reactions
      # @param [Array] all_chunks the list of all chunks which will be recombined
      #   between each other for detect unresolved lateral reactions
      # @return [Array] the list of builded lateral reactions
      def combine_laterals(all_chunks)
        combiner = ChunksCombiner.new(self)
        combiner.combine(all_chunks)
      end

      # Organizes dependencies between chunks by dynamic programming table
      # @param [Array] chunks the list of chunks each item of which will be organized
      # @return [Array] the list of all different chunks which could take plase on
      #   surface under simulation
      def organize_chunks!(chunks)
        raise 'Same chunks presented' if chunks.combination(2).any?(&:same?)

        table = ChunksTable.new(chunks)
        chunks + chunks.reduce([]) do |independent_chunks, chunk|
          chunk.organize_dependencies!(table, independent_chunks)
        end
      end
    end

  end
end
