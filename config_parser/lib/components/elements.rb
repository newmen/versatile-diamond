class Elements < Component
  def atom(name, valence: nil)
    syntax_error('atom.without_valence') unless valence
    Atom.add(name, valence)
  end
end
