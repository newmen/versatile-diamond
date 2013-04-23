class AtomicSpec < TerminationSpec
  def initialize(atom_name)
    @atom = Atom[atom_name]
    # TODO: maybe need to check that atom valence is 1
  end

  def name
    @atom.name
  end

  def external_bonds
    @atom.valence
  end

  def to_s
    @atom.to_s
  end
end
