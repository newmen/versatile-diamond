module VersatileDiamond
  module Organizers

    # Provides logic for organization parent chunks
    module ChunkParentsOrganizer

      # Gets using source chunks
      # @return [Array] the list of using soruce chunks
      def internal_chunks
        @_internal_chunks ||=
          parents.empty? ? [self] : parents.flat_map(&:internal_chunks)
      end

      # Reorganizes the parent chunks
      def reorganize_parents!
        @parents = parents.reduce(parents) do |acc, parent|
          acc.reject { |ch| parent.parents.include?(ch) }
        end
      end
    end

  end
end
