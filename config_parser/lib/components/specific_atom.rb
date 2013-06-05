module VersatileDiamond

  class SpecificAtom
    def initialize(atom)
      @atom = atom
      @options = []
    end

    %w(incoherent unfixed).each do |state|
      define_method("#{state}!") do
        # TODO: translate error and extract it feature to solo module
        raise "State #{state} already setted for #{@atom}" if @options.include?(state.to_sym)
        @options << state.to_sym
      end
    end

    def active!
      # TODO: translate error (see todo above)
      raise 'Atom cannot be activated more than own valence' if @options.select { :active }.size > @atom.valence
      @options << :active
    end

    def same?(other)
      if self.class == other.class
        @atom == other.atom && (@options - other.options).empty? && @options.size == other.options.size
      else
        false
      end
    end

  protected

    attr_reader :atom, :options

  end

end
