class Events < ComplexComponent
  def reaction(name)
    nested(Reaction.new(name))
  end

#   def shared_lateral(*args)
# p args
#   end
end
