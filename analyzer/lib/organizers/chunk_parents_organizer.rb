module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Provides logic for organization parent chunks
    module ChunkParentsOrganizer
      include Modules::ListsComparer

      # Gets using source chunks
      # @return [Array] the list of using soruce chunks
      def internal_chunks
        return @_internal_chunks if @_internal_chunks
        parents.empty? ? [self] : parents.flat_map(&:internal_chunks)
      end

      # Remembers using internal chunks
      def remember_internal_chunks!
        @_internal_chunks = internal_chunks
      end

      # Reorganizes the parent chunks
      # @param [Array] all_chunks which will interpreted and combined
      def reorganize_parents!(all_chunks)
        possible_parents = all_chunks.select do |chunk|
          next false if chunk == self
          next false if chunk.internal_chunks.size > internal_chunks.size
          ichs_dup = internal_chunks.dup
          chunk.internal_chunks.all? { |pr| ichs_dup.delete_one(pr) }
        end

        max_num = possible_parents.map { |pr| pr.internal_chunks.size }.max
        maximal_parents = possible_parents.select do |pr|
          pr.internal_chunks.size == max_num
        end

        is_fail = maximal_parents.combination(2).any? do |a, b|
          lists_are_identical?(a.internal_chunks, b.internal_chunks, &:==)
        end
        binding.pry if is_fail
        raise 'Similar parents of selected parents' if is_fail

        own_parents_dup = internal_chunks - [self]
        maximal_parents.each do |pr|
          pr.internal_chunks.each { |ch| own_parents_dup.delete_one(ch) }
        end

        @parents = own_parents_dup + maximal_parents
      end
    end

  end
end
