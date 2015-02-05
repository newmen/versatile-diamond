module VersatileDiamond
  module Concepts

    # Provides logic for compare positions
    module PositionsComparer
      class << self
        # Compares two tuples of positions
        # @param [Array] pos1 the first tuple of positions
        # @param [Array] pos2 the second tuple of positions
        # @return [Boolean] are same or not
        def same_pos_tuples?(pos1, pos2)
          pos1.last == pos2.last && [0, 1].all? do |i|
            [0, 1].all? { |j| pos1[i][j].same?(pos2[i][j]) }
          end
        end
      end

      # Reduce all positions from links structure
      # @return [Array] the array of position tuples
      # TODO: must be protected
      def positions
        make_positions(links)
      end

      # Compares positions of two reactions and checks that are same
      # @param [Reaction] other the comparing reaction
      # @return [Boolean] are same positions or not
      # TODO: rspec
      def same_positions?(other)
        same_by_method?(:positions, other)
      end

    private

      # Compares the lists from current and other instances which will be gotten by
      # passed method name
      #
      # @param [Symbol] method name which uses for getting the comparing lists
      # @return [Boolean] are identical gotten lists or not
      def same_by_method?(method, other)
        pos_compr_method = PositionsComparer.method(:same_pos_tuples?)
        lists_are_identical?(send(method), other.send(method), &pos_compr_method)
      end

      # Gets the list of position tuples which combines from passed graph
      # @param [Hash] graph from which the data will be recombined
      # @return [Array] the list of position tuples
      def make_positions(graph)
        graph.flat_map do |spec_atom, rels|
          rels.map do |other_spec_atom, position|
            [spec_atom, other_spec_atom, position]
          end
        end
      end
    end

  end
end
