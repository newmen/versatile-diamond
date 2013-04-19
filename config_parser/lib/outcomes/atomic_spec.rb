class AtomicSpec < TerminationSpec
  def initialize(atom_name)
    @atom = Atom[atom_name]
  end
end
