class Events < ComplexComponent
  def reaction(name)
    nested(Reaction.add(name))
  end
end
