module VersatileDiamond

  class ConcreteWhere
    extend Forwardable
    include Linker

    attr_reader :where

    def initialize(where, raw_positions, target_refs)
      @where = where

      raw_positions.each do |target_alias, link|
        atom, position = link
        link(:@links, target_refs[target_alias], atom, position)
      end
    end

    def_delegator :@where, :description

    def visit(visitor)
      visitor.accept_where(@where)
    end
  end

end
