class AtomReference
  def initialize(spec, atom_keyname)
    @spec, @atom_keyname = spec, atom_keyname
  end

  def valence
    @spec.external_bonds_for(@atom_keyname)
  end

  def specified?
    @spec[@atom_keyname].specified?
  end

  def to_s
    @spec[@atom_keyname].to_s
  end
end
