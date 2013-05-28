module VersatileDiamond

  class AtomReference
    extend Forwardable

    attr_reader :spec, :atom

    def initialize(spec, atom_keyname)
      @spec, @atom_keyname = spec, atom_keyname
      @atom = @spec[@atom_keyname]
    end

    def_delegators :@atom, :name, :lattice, :same?

    def valence
      @spec.external_bonds_for(@atom_keyname)
    end

    def specified?
      @atom.specified?
    end

    def to_s
      "&#{@atom}"
    end
  end

end
