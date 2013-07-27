module VersatileDiamond
  module Concepts

    # Specified atom class, contain additional atom states like incoherentness,
    # unfixness and activeness
    class SpecificAtom

      # Error for case if state for atome already exsit
      class AlreadyStated < Exception; end

      extend Forwardable
      def_delegator :@atom, :lattice

      # @param [Atom] atom the specified atom
      def initialize(atom)
        @atom = atom
        @options = []
      end

      # Activates atom instance
      def active!
        @options << :active
      end

      %w(incoherent unfixed).each do |state|
        sym_state = state.to_sym
        # Defines methods for changing atom state
        # @raise [AlreadyStated] if atom already has setuping state
        define_method("#{state}!") do
          raise AlreadyStated if send("#{sym_state}?")
          @options << sym_state
        end

        define_method("#{state}?") do
          @options.include?(sym_state)
        end
      end

      # Counts active bonds
      # @return [Integer] the number of active bonds
      def actives
        @options.select { |o| o == :active }.size
      end

      # def same?(other)
      #   if self.class == other.class
      #     @atom == other.atom && (@options == other.options ||
      #       (@options.size == other.options.size &&
      #         @options.sort == other.options.sort))
      #   else
      #     false
      #   end
      # end

      # def diff(other)
      #   if self.class == other.class
      #     other.relevants - relevants
      #   else
      #     relevants
      #   end
      # end

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

      # attr_reader :atom
      # attr_reader :options

      # def relevants
      #   @options - [:active]
      # end
    end

  end
end
