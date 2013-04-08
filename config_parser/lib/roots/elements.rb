class Elements
  def atom(name, valence: nil)
    raise ArgumentError, 'Atom cannot be initialized without valence parameter' unless valence
    Atom.add(name, valence)
  end
end
