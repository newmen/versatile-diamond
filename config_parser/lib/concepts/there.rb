module VersatileDiamond
  module Concepts

    # Implrements which know about environment specs and has info about
    # positions between reactants and environment specs
    class There
      extend Forwardable

      # attr_reader :where

      # Initialize a new instance of there object
      # @param [Where] where the basic where object
      # @param [Hash] positions the hash where keys is atoms of reactants and
      #   values is hashes of environment specs atoms to position objects
      def initialize(where, positions)
        @where, @positions = where, positions
      end

      def_delegators :@where, :specs, :description

      # def visit(visitor)
      #   visitor.accept_where(@where)
      # end

      # def same?(other)
      #   @where.environment == other.where.environment &&
      #     @where.description == other.where.description
      # end

      # def cover?(other)
      #   @where.dependent_from.include?(other.where)
      # end
    end

  end
end
