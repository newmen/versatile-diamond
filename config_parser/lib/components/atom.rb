class Atom
  class << self
    def [](name)
      @atoms[name] && @atoms[name].dup
    end

    def add(name, valence)
      @atoms ||= {}
      @atoms[name] = new(name, valence)
    end
  end

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
