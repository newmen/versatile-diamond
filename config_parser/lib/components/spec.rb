class Spec
  class << self
    def [](name)
      @specs[name.to_sym]
    end

    def add(name, &block)
      @specs ||= {}
      @specs[name] = new(name, &block)
    end
  end

  def initialize(name, &block)
    @name = name
    instance_eval(&block)
  end

  def [](atom)
    @atoms[atom]
  end

  def aliases(**refs)
    @aliases = refs
  end

  def atoms(**refs)
    @atoms = refs
  end

  def const_missing(name)
    # TODO: maybe need to specify error message when atom is not found
    Atom[name] || super
  end

  def method_missing(name, *args)
    name = name.to_sym
    spec = self.class[name] || (name == @name && self)
    if spec
      args.empty? ? spec : spec[args.first]
    else
      # TODO: maybe need to specify error too
      super
    end
  end
end
