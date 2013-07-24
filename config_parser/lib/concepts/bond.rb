module VersatileDiamond

  module Concepts

    class Bond
      def self.[](face: nil, dir: nil)
        key = face.to_s
        key << "_#{dir}" if dir
        @consts ||= {}
        @consts[key] ||= new(face, dir)
      end

      def initialize(face, dir)
        @face, @dir = face, dir
      end

      def same?(other)
        self.class == other.class || other.same?(self)
      end

      def to_s
        symbol = '-'
        str = symbol.dup
        str << "#{@face}#{symbol}" if @face
        str << "#{@dir}#{symbol}" if @dir
        "#{str}#{symbol}"
      end

    protected

      attr_reader :face, :dir

    end

  end

end
