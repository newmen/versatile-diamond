module VersatileDiamond
  module Organizers

    # Provides common logic for another minuend modules
    module Minuend
      include Modules::ListsComparer
      include Modules::OrderProvider
      include Modules::ProcsReducer

      # Compares two minuend instances
      # @param [Minuend] other the comparable minuend instance
      # @return [Integer] the result of comparation
      def <=> (other)
        compare_with(other)
      end

      # Checks that current instance is less than other
      # @param [Minuend] other the comparable minuend instance
      # @return [Boolean] is less or not
      def < (other)
        compare_with(other, strong_types_order: false) < 0
      end

      # Checks that current instance is less than other or equal
      # @param [Minuend] other the comparable minuend instance
      # @return [Boolean] is less or equal or not
      def <= (other)
        self == other || self < other
      end

      # Makes residual of difference between top and possible parent
      # @param [Object] other the subtrahend entity
      # @return [SpecResidual | ChunkResidual] the residual of diference between
      #   arguments or nil if it doesn't exist
      def - (other)
        mirror = mirror_to(other)
        other.links.size == mirror.size ? subtract(other, mirror) : nil
      end

    protected

      # Counts the relations number in current links
      # @return [Integer] the number of relations
      def relations_num
        links.values.map(&:size).reduce(:+)
      end

    private

      # Compares two minuend instances
      # @param [Minuend] other the comparable minuend instance
      # @option [Boolean] :strong_types_order is the flag which if set then types info
      #   also used for ordering
      # @return [Integer] the result of comparation
      def compare_with(other, strong_types_order: true)
        procs = []
        procs << -> &block { order(self, other, :links, :size, &block) }
        procs << -> &block { order_classes(other, &block) } if strong_types_order
        procs << -> &block { order_relations(other, &block) }

        reduce_procs(procs, &comparing_core(other)).call
      end

      # Provides comparison by number of relations
      # @param [Minuend] other see at #<=> same argument
      # @return [Integer] the result of comparation
      def order_relations(other, &block)
        order(self, other, :relations_num, &block)
      end

      # Subtracts other entity from current
      # @param [Object] other the subtrahend spec
      # @param [Hash] mirror from self to other spec
      # @yield [Object] pass the own key when both keys in the pair are different
      # @return [SpecResidual | ChunkResidual] substraction result
      def rest_links(other, mirror, &block)
        pairs_from(mirror).each_with_object({}) do |(own_key, other_key), rest|
          unless other_key
            rest[own_key] = links[own_key] # <-- same as bottom
            next
          end

          if different_or_used?(other, own_key, other_key, mirror.keys)
            rest[own_key] = links[own_key] # <-- same as top
            block[own_key] if block_given?
          end
        end
      end

      # Makes pairs of keys from mirror. If some keys from current links are not
      # presented in mirror then them will be added to head of pairs.
      #
      # @param [Hash] mirror of keys from current spec to subtrahend spec
      # @return [Array] the array of keys pairs
      def pairs_from(mirror)
        pairs = mirror.to_a
        if pairs.size < links.size
          (links.keys - mirror.keys).each do |residual_atom|
            pairs.unshift([residual_atom, nil])
          end
        end
        pairs
      end

      # Checks that passed pair of keys contain different or used keys
      def different_or_used?(other, own_key, other_key, mirrored_keys)
        different_used_relations?(other, own_key, other_key) ||
          used?(mirrored_keys, own_key)
      end

      # Checks that relations gotten by method of both key have same relations sets
      # @param [Symbol] method name which will called
      # @param [Minuend] other same as #- argument
      # @param [Object] own_key the major comparable keys
      # @param [Object] other_key the second comparable key
      # @return [Boolean] are different or not
      def different_by?(method, other, own_key, other_key)
        srs, ors = send(method, own_key), other.send(method, other_key)
        !lists_are_identical?(srs, ors, &:==)
      end

      # Checks that bonds of both key have same relations sets
      # @param [Minuend] other same as #- argument
      # @param [Object] own_key same as #different_by? argument
      # @param [Object] other_key same as #different_by? argument
      # @return [Boolean] are different or not
      def different_used_relations?(*args)
        different_by?(:used_relations_of, *args)
      end

      # Checks whether the key is used in current links
      # @param [Array] mirrored_keys the keys which was mapped to keys of subtrahend
      # @param [Object] key the checkable key
      # @return [Boolean] is used or not
      def used?(mirrored_keys, key)
        (links.keys - mirrored_keys).any? do |k|
          links[k].any? { |neighbour, r| neighbour?(k, neighbour, key, r) }
        end
      end
    end

  end
end
