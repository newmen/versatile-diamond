module VersatileDiamond
  module Organizers

    # Provides methods for compare chunks between them
    module ChunksComparer
      include Modules::ListsComparer
      include Modules::OrderProvider
      include Mcs::SpecsAtomsComparator

      # Compares two chunk between each other
      # @param [ChunkComparer] other comparing chunk
      # @return [Integer] comparison result
      def <=> (other)
        typed_order(other, self, ChunkResidual) do # always at begin of ordered seq
          comparing_core(other) do
            typed_order(self, other, MergedChunk) do
              typed_order(self, other, Chunk) do
                typed_order(self, other, TargetReplacedChunk) do
                  typed_order(self, other, IndependentChunk)
                end
              end
            end
          end
        end
      end

      # Counts total number of links
      # @return [Integer] the number of links
      def total_links_num
        @_total_links_num ||= links.reduce(0) { |acc, rels| acc + rels.size }
      end

      # Compares two chunk instances and check that them are same
      # @param [ChunksComparer] other chunk which will be compared
      # @return [Boolean] is same other chunk or not
      def same?(other)
        check_same?(other, method(:same_sa?), :mirror_to)
      end

      # Accurate compares two chunk instances and check that them are same
      # @param [ChunksComparer] other chunk which will be compared
      # @return [Boolean] is same other chunk or not
      def accurate_same?(other)
        check_same?(other, :==, :accurate_mirror_to)
      end

      # Compares self and other lists of internal chunks
      # @param [ChunksComparer] other chunk which will be compared
      # @return [Boolean] is same internal chunks or not
      def same_internals?(other)
        equal?(other) ||
          (same_targets?(other, &method(:same_sa?)) &&
            links.size == other.links.size &&
            lists_are_identical?(internal_chunks, other.internal_chunks, &:same?))
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
        make_mirror(other) do |ts, sa1, sa2|
          (ts.all? || !ts.any?) && same_sa?(sa1, sa2)
        end
      end

      # Makes accurate mirror with other chunk
      # @param [ChunksComparer] other chunk to which the mirror will be builded
      # @return [Hash] the accurate mirror from self chunk to other chunk
      def accurate_mirror_to(other)
        make_mirror(other) do |ts, sa1, sa2|
          if ts.all?
            sa1 == sa2
          elsif !ts.any?
            same_sa?(sa1, sa2)
          else
            false
          end
        end
      end

      # Makes mirror with other chunk
      # @param [ChunksComparer] other chunk to which the mirror will be builded
      # @yield [Array, Array, Array] iterates target checking and targets from both
      #   chunks
      # @return [Hash] the mirror from self chunk to other chunk
      def make_mirror(other, &block)
        Mcs::SpeciesComparator.make_mirror(self, other) do |_, _, sa1, sa2|
          ts = [target?(sa1), other.target?(sa2)]
          block[ts, sa1, sa2]
        end
      end

      # Gets core for ordering chunks
      # @param [ChunkComparer] other comparing chunk
      # @yield do internal compares if total links numbers are equal
      # @return [Integer] comparison result
      def comparing_core(other, &block)
        a, b = [relations, other.relations].map { |rs| rs.map(&:to_s) }
        if a == b || a.size != b.size
          order(self, other, :clean_links, :size) do
            compare_total_links_num(other, &block)
          end
        else
          a <=> b
        end
      end

      # Compares two chunks by number of total links num
      # @param [ChunkComparer] other comparing chunk
      # @yield do internal compares if total links numbers are equal
      # @return [Integer] comparison result
      def compare_total_links_num(other, &block)
        order(self, other, :total_links_num, &block)
      end

      # Compares two chunk instances and check that them are same
      # @param [ChunksComparer] other chunk which will be compared
      # @param [Proc] targets_cm_proc by which targets will compared
      # @param [Symbol] mirror_method name for build the mirror between chunks
      # @return [Boolean] is same other chunk or not
      def check_same?(other, targets_cm_proc, mirror_method)
        return true if equal?(other)
        return false unless same_targets?(other, &targets_cm_proc)
        lsz = links.size
        other.links.size == lsz &&
          ((targets.size == lsz && targets.all? { |t| links[t] }) ||
            send(mirror_method, other).size == lsz)
      end

      # Checks that targets of current and other are same
      # @param [ChunksComparer] other chunk which targets will be checked
      # @yield [Array, Array] compares each pair of targets
      # @return [Boolean] are similar targets in current and other chunks or not
      def same_targets?(other, &block)
        lists_are_identical?(targets.to_a, other.targets.to_a, &block)
      end
    end

  end
end
