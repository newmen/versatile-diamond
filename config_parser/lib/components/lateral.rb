module VersatileDiamond

  class Lateral
    extend Forwardable

    def initialize(environment, **target_refs)
      @environment, @target_refs = environment, target_refs
    end

    def_delegator :@environment, :use_where, :has_where?

    def concretize_where(name)
      @environment.use_where(name).concretize(@target_refs)
    end
  end

end
