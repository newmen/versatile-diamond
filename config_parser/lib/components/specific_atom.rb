module VersatileDiamond

  class SpecificAtom
    def initialize(atom)
      @atom = atom
      @options = []
    end

    %w(active incoherent unfixed).each do |state|
      define_method("#{state}!") do
        @options << state.to_sym
      end
    end

    def same?(other)
      if self.class == other.class
        @atom == other.atom && (@options == other.options ||
          (@options.size == other.options.size && @options.sort == other.options.sort))
      else
        false
      end
    end

    def to_s
      chars = @options.map do |value|
        case value
        when :active then '*'
        when :incoherent then 'i'
        when :unfixed then 'u'
        end
      end
      "[#{chars.sort.join(', ')}]"
    end

  protected

    attr_reader :atom, :options

  end

end
