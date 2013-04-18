class Atom
  class << self
    include SyntaxChecker

    def [](name)
      (@atoms[name] && @atoms[name].dup) || syntax_error('.undefined', name: name)
    end

    def add(name, valence)
      @atoms ||= {}
      syntax_error('.already_defined', name: name) if @atoms[name]
      @atoms[name] = new(name, valence)
    end
  end

  attr_reader :valence

  def initialize(name, valence)
    @name, @valence = name, valence
  end

  def specify(lattice)
    @lattice = lattice
  end

  def specified?
    !!@lattice
  end
end
