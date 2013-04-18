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
end
