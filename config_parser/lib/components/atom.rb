module VersatileDiamond

  class Atom
    class << self
      include SyntaxChecker

      def [](name)
        (@atoms[name] && @atoms[name].dup) ||
          syntax_error('.undefined', name: name)
      end

      def add(name, valence)
        @atoms ||= {}
        syntax_error('.already_defined', name: name) if @atoms[name]
        @atoms[name] = new(name, valence)
      end
    end

    attr_reader :name, :valence
    attr_accessor :lattice

    def initialize(name, valence)
      @name, @valence = name, valence
    end

    def to_s
      @lattice ? "#{name}%#{@lattice}" : @name
    end

    def same?(other)
      if self.class == other.class
        @name == other.name && @lattice == other.lattice
      else
        other.same?(self)
      end
    end
  end

end
