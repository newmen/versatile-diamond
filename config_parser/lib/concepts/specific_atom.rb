module VersatileDiamond
  module Concepts

    # Specified atom class, contain additional atom states like incoherentness,
    # unfixness and activeness
    class SpecificAtom

      # Error for case if state for atome already exsit
      class AlreadyStated < Exception
        attr_reader :state
        def initialize(state); @state = state end
      end

      extend Forwardable
      def_delegators :@atom, :name, :lattice, :lattice=

      # Initialize a new instance
      # @param [Atom] atom the specified atom
      # @option [SpecificAtom] :ancestor the ancestor of new file
      # @option [Array] :options the atom configuration (not using if ancestor
      #   passed)
      def initialize(atom, ancestor: nil, options: [])
        @atom = atom.dup # because atom can be changed by mapping algorithm
        @options = ancestor ? ancestor.options : options
      end

      # Makes copy of another instance
      # @param [SpecificAtom] other an other specified atom
      def initialize_copy(other)
        @atom = other.atom.dup
        @options = other.options.dup
      end

      # Gets valence of specific atom
      # @return [Integer] the number of valence bonds
      def valence
        @atom.valence - actives
      end

      # Compares current instance with other
      # @param [Atom | AtomReference | SpecificAtom] other the other atom with
      #   which comparing do
      # @return [Boolean] is the same atom or not
      def same?(other)
        if self.class == other.class
          @atom.same?(other.atom) && @options.sort == other.options.sort
        else
          false
        end
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
          raise AlreadyStated.new(state) if send("#{sym_state}?")
          @options << sym_state
        end

        # Defines methods for checking atom state
        # @return [Boolean] is atom has state or not
        define_method("#{state}?") do
          @options.include?(sym_state)
        end
      end

      # Counts active bonds
      # @return [Integer] the number of active bonds
      def actives
        @options.select { |o| o == :active }.size
      end

      # Compares with other atom
      # @param [Atom | AtomReference | SpecificAtom] other the atom with which
      #   compare
      # @return [Array] the array of relevants state symbols
      def diff(other)
        self.class == other.class ? other.relevants - relevants : []
      end

      # Gets only relevant states
      # @return [Array] the array of relevant states
      def relevants
        @options - [:active]
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

      attr_reader :atom, :options

    end

  end
end
