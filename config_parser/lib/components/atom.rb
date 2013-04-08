class Atom
  class << self
    def [](name)
      @atoms[name.to_sym].dup
    end

    def add(name, valence)
      @atoms ||= {}
      @atoms[name] = new(name, valence)
    end
  end

  def initialize(name, valence)
    @name, @valence = name, valence
  end

  # Specification the atom
  def %(lattice)
    @lattice = lattice
  end
end
