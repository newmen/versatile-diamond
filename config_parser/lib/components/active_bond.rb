module VersatileDiamond

  class ActiveBond < TerminationSpec
    include Singleton

    def name
      '*'
    end

    def external_bonds
      0
    end

    def to_s
      name
    end
  end

end
