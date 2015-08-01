module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Provides logic for organization parent chunks
    module ChunkParentsOrganizer
      include Modules::ExtendedCombinator
      include Modules::ListsComparer

      # Gets using source chunks
      # @return [Array] the list of using soruce chunks
      def internal_chunks
        return @_internal_chunks if @_internal_chunks
        parents.empty? ? [self] : parents.flat_map(&:internal_chunks)
      end

      # Remembers using internal chunks
      def remember_internal_chunks!(all_chunks)
        @_internal_chunks = select_same_from(all_chunks, internal_chunks, &:same?)
      end

      # Reorganizes the parent chunks
      # @param [Array] all_chunks the list of all available ordered chunks
      def reorganize_parents!(all_chunks)
        possible_parents = all_chunks.select do |chunk|
          next false if chunk == self
          next false if chunk.internal_chunks.size >= internal_chunks.size
          ichs_dup = internal_chunks.dup
          chunk.internal_chunks.all? { |pr| ichs_dup.delete_one(pr) }
        end

        original_parents = possible_parents.select(&:deep_original?)
        original_parents = possible_parents if original_parents.empty?
        max_num = original_parents.map { |pr| pr.internal_chunks.size }.max
        maximal_parents = possible_parents.select do |pr|
          pr.internal_chunks.size == max_num
        end

        own_parents_dup = internal_chunks - [self]
        rm_parent_lambda = -> ch { own_parents_dup.delete_one(ch) }
        maximal_parents.each { |pr| pr.internal_chunks.each(&rm_parent_lambda) }

        own_parents_slices = sliced_combinations(own_parents_dup, 1).reverse
        available_same = all_chunks.find do |chunk|
          own_parents_slices.any? do |slice|
            slice.any? do |prs|
              lists_are_identical?(chunk.internal_chunks, prs, &:same?) &&
                prs.each(&rm_parent_lambda)
            end
          end
        end

        available_same = available_same ? [available_same] : []
        @parents = own_parents_dup + available_same + maximal_parents
      end

      # Check that self or any other parents are original
      # @return [Boolean] have original parent or not
      def deep_original?
        original? || parents.any?(&:deep_original?)
      end

    private

      # Selects same chunk from all chunks for passed chunks
      # @param [Array] all_chunks which are available
      # @param [Array] for_chunks the same chunks list should be gotten
      # @yield [ChunkParentsOrganizer, ChunkParentsOrganizer] for each pairs of chunks
      # @return [Array] the list of same chunks
      def select_same_from(all_chunks, for_chunks, &block)
        for_chunks.map do |chunk|
          all_chunks.find { |ch| block[chunk, ch] } || chunk
        end
      end
    end

  end
end
