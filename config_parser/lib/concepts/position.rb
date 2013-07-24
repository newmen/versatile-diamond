module VersatileDiamond

  module Concepts

    class Position < Bond
      include Modules::SyntaxChecker

      def self.[](face: nil, dir: nil)
        syntax_error('.uncomplete') unless face && dir
        super(face: face, dir: dir)
      end

      def same?(other)
        face == other.face && dir == other.dir
      end

      def to_s
        symbol = ':'
        "#{symbol}#{@face}#{symbol}#{@dir}#{symbol}#{symbol}"
      end
    end

  end

end
