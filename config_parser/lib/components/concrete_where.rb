module VersatileDiamond

  class ConcreteWhere
    extend Forwardable

    attr_reader :where

    def initialize(where, raw_positions, target_refs)
      @where = where
      @positions = {}

      raw_positions.each do |target_alias, link|
        atom = target_refs[target_alias]
        @positions[atom] = link
      end
    end

    def_delegator :@where, :description

    def visit(visitor)
      visitor.accept_where(@where)
    end

    def same?(other)
      @where.environment == other.where.environment &&
        @where.description == other.where.description
    end
  end

end
