module VersatileDiamond
  module Organizers

    # Provides methods for compare chunks between them
    module ChunksComparer
      include Modules::OrderProvider
      include Mcs::SpecsAtomsComparator

      # Compares two chunk between each other
      # @param [ChunkComparer] other comparing chunk
      # @return [Integer] comparison result
      def <=> (other)
        typed_order(self, other, MergedChunk) do
          typed_order(self, other, Chunk) do
            typed_order(self, other, IndependentChunk) do
              typed_order(self, other, ChunkResidual) do
                comparing_core(other)
              end
            end
          end
        end
      end

      # Counts total number of links
      # @return [Integer] the number of links
      def total_links_num
        links.reduce(0) { |acc, rels| acc + rels.size }
      end

      # Compares two chunk instances and check that them are same
      # @param [ChunksComparer] other chunk which will be compared
      # @return [Boolean] is same other chunk or not
      def same?(other)
        return true if equal?(other)
        return false unless same_targets?(other)
        lsz = links.size
        other.links.size == lsz &&
          (targets.size == lsz || mirror_to(other).size == lsz)
      end

    protected

      # Checks that passed spec-atom instance is target of current chunk
      # @param [Array] sa the one of key of links
      # @return [Boolean] is target spec-atom or not
      def target?(sa)
        targets.include?(sa)
      end

    private

      # Makes mirror with other chunk or chunk resudual
      # @param [ChunksComparer] other chunk to which the mirror will be builded
      # @return [Hash] the mirror from self chunk to other chunk
      def mirror_to(other)
        Mcs::SpeciesComparator.make_mirror(self, other) do |_, _, sa1, sa2|
          ts = [target?(sa1), other.target?(sa2)]
          (ts.all? || !ts.any?) && same_sa?(sa1, sa2)
        end
      end

      # Gets core for ordering chunks
      # @param [ChunkComparer] other comparing chunk
      # @return [Integer] comparison result
      def comparing_core(other)
        order(self, other, :clean_links, :size) do
          compare_total_links_num(other)
        end
      end

      # Compares two chunks by number of total links num
      # @param [ChunkComparer] other comparing chunk
      # @yield do internal compares if total links numbers are equal
      # @return [Integer] comparison result
      def compare_total_links_num(other, &block)
        order(self, other, :total_links_num, &block)
      end

      # Checks that targets of current and other are same
      # @param [ChunksComparer] other chunk which targets will be checked
      # @return [Boolean] are similar targets in current and other chunks or not
      def same_targets?(other)
        lists_are_identical?(targets, other.targets, &method(:same_sa?))
      end
    end

  end
end
