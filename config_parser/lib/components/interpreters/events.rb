module VersatileDiamond

  class Events < ComplexComponent
    def reaction(name)
      nested(Reaction.new(name))
    end

    def environment(name)
      nested(Environment.add(name))
    end
  end

end
