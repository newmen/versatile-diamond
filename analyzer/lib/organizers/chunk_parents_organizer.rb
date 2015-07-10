module VersatileDiamond
  module Organizers

    # Provides logic for organization parent chunks
    module ChunkParentsOrganizer
      # Reorganizes the parent chunks
      def reorganize_parents!
        @parents = parents.reduce(parents) do |acc, parent|
          acc.reject { |ch| parent.parents.include?(ch) }
        end
      end
    end

  end
end
