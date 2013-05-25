module VersatileDiamond

  class Position < Bond
    include SyntaxChecker

    def self.[](face: nil, dir: nil)
      syntax_error('.uncomplete') unless face && dir
      super
    end

    def to_s
      '.'
    end
  end

end
