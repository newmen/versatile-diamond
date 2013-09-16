module VersatileDiamond
  module Concepts

    # Implrements which know about environment specs and has info about
    # positions between reactants and environment specs
    class There
      extend Forwardable

      attr_reader :where # only for visitor

      # Initialize a new instance of there object
      # @param [Where] where the basic where object
      # @param [Hash] positions the hash where keys is atoms of reactants and
      #   values is hashes of environment specs atoms to position objects
      def initialize(where, positions)
        @where, @positions = where, positions
      end

      def_delegators :@where, :description, :swap_source, :visit

      # Provides environment species
        # @return [Array] all species stored in used where and in their parents
      def specs
        @where.all_specs
      end

      # Compares two there objects
      # @param [There] other with which comparison
      # @return [Boolean] are their wheres equal
      def same?(other)
        where == other.where
      end

      # Verifies that passed there object is covered by the current
      # @param [There] other the verifying there object
      # @return [Boolean] is cover or not
      def cover?(other)
        other.where.parents.include?(@where)
      end

      # Counts number of environment used atoms
      # @return [Integer] the number of used atoms
      def size
        specs.reduce(0) { |acc, spec| acc + spec.size }
      end
    end

  end
end
