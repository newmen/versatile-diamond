class Events < ComplexComponent
  def reaction(name)
    nested(Reaction.new(name))
  end
end
