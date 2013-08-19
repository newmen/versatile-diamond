module VersatileDiamond
  module Concepts

    # TODO: rspec
    class There
      extend Forwardable

      # attr_reader :where

      def initialize(where, positions)
        @where, @positions = where, positions
      end

      def_delegator :@where, :description

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
