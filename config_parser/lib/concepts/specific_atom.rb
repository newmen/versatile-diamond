module VersatileDiamond

  module Concepts

    class SpecificAtom
      extend Forwardable

      # attr_reader :atom

      def initialize(atom)
        @atom = atom
        @options = []
      end

      def_delegator :@atom, :lattice

      %w(active incoherent unfixed).each do |state|
        sym_state = state.to_sym
        define_method("#{state}!") do
          @options << sym_state
        end

        define_method("#{state}?") do
          @options.include?(sym_state)
        end
      end

      def same?(other)
        if self.class == other.class
          @atom == other.atom && (@options == other.options ||
            (@options.size == other.options.size &&
              @options.sort == other.options.sort))
        else
          false
        end
      end

      def diff(other)
        if self.class == other.class
          other.relevants - relevants
        else
          relevants
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
        "#{@atom}[#{chars.sort.join(', ')}]"
      end

    protected

      attr_reader :atom
      attr_reader :options

      def relevants
        @options - [:active]
      end
    end

  end

end
