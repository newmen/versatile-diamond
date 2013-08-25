module VersatileDiamond
  module Concepts

    # Implrements which know about environment specs and has info about
    # positions between reactants and environment specs
    class There
      extend Forwardable

      # Initialize a new instance of there object
      # @param [Where] where the basic where object
      # @param [Hash] positions the hash where keys is atoms of reactants and
      #   values is hashes of environment specs atoms to position objects
      def initialize(where, positions)
        @where, @positions = where, positions
      end

      def_delegators :@where, :specs, :description, :visit

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

    protected

      attr_reader :where

    end

  end
end
