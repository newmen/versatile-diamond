module VersatileDiamond
  module Concepts

    # Specified atom class, contain additional atom states like incoherentness,
    # unfixness and activeness
    class SpecificAtom
      extend Forwardable

      # Error for case when something wrong with atom state
      # @abstract
      class Stated < Errors::Base
        attr_reader :state
        def initialize(state); @state = state end
      end

      # Error for case if state for atom already exsit
      class AlreadyStated < Stated; end

      # Error for case if state for atom doesn't exsit
      class NotStated < Stated; end

      def_delegators :@atom, :name, :lattice, :lattice=, :original_valence,
        :original_same?

      attr_reader :monovalents

      # Initialize a new instance
      # @param [Atom] atom the specified atom
      # @option [SpecificAtom] :ancestor the ancestor of new atom
      # @option [Array] :options the atom configuration (not using if ancestor
      #   passed)
      # @option [Array] :monovalents names of monovalent atoms with which
      #   the current atom is bonded
      def initialize(atom, ancestor: nil, options: [], monovalents: [])
        @atom = atom.dup # because atom can be changed by mapping algorithm
        @options = ancestor ? ancestor.options : options
        @monovalents = ancestor ? ancestor.monovalents : monovalents
      end

      # Makes copy of another instance
      # @param [SpecificAtom] other an other specified atom
      def initialize_copy(other)
        @atom = other.atom.dup
        @options = other.options.dup
        @monovalents = other.monovalents.dup
      end

      # Gets valence of specific atom
      # @return [Integer] the number of valence bonds
      def valence
        @atom.valence - actives - monovalents.size
      end

      # Compares current instance with other
      # @param [Atom | AtomReference | SpecificAtom] other the other atom with
      #   which comparing do
      # @return [Boolean] is the same atom or not
      def same?(other)
        if self.class == other.class
          @atom.same?(other.atom) && @options.sort == other.options.sort &&
            monovalents.sort == other.monovalents.sort
        else
          @options.empty? && @monovalents.empty? && @atom.same?(other)
        end
      end

      # Setup monovalent atom for using it
      # @param [Atom] atom the monovalent atom which is used as one of bond
      def use!(atom)
        @monovalents << atom.name
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

        # Defines methods for unsetup atom state
        # @raise [NotStated] if atom doesn't have target state
        define_method("not_#{state}!") do
          raise NotStated.new(state) unless send("#{sym_state}?")
          @options.delete(sym_state)
        end
      end

      # Counts active bonds
      # @return [Integer] the number of active bonds
      def actives
        active_options.size
      end

      # Compares relevant states with states of another atom. Used in Hanser's
      # algorithm.
      #
      # @param [Atom | AtomReference | SpecificAtom] other the atom with which
      #   compares
      # @return [Array] the array of relevants state symbols
      def diff(other)
        self.class == other.class ? other.relevants - relevants : []
      end

      # Applies diff to current options
      # @param [Array] diff the array which contain adsorbing states
      def apply_diff(diff)
        diff.each { |state| send(:"#{state}!") }
      end

      # Gets only relevant states
      # @return [Array] the array of relevant states
      def relevants
        @options - [:active]
      end

      # Finds all relation instances for current atom in passed spec
      # @param [SpecificSpec] specific_spec the spec in which relations will be
      #   found, must contain current atom
      # @return [Array] the array of relations
      def relations_in(specific_spec)
        specific_spec.links[self] + @atom.additional_relations +
          active_options + monovalents
      end

      # Gets the relevant size of specific atom
      # @return [Float] the relevant size of specific atom
      def size
        (actives + monovalents.size) * 0.34 + relevants.size * 0.13
      end

      def to_s
        chars = @options.map do |value|
          case value
          when :active then '*'
          when :incoherent then 'i'
          when :unfixed then 'u'
          end
        end
        chars += monovalents.map(&:to_s)
        "#{@atom}[#{chars.sort.join(', ')}]"
      end

      def inspect
        to_s
      end

    protected

      attr_reader :atom, :options

    private

      # Selects only :active options
      # @return [Array] array of :active options
      def active_options
        @options.select { |o| o == :active }
      end
    end

  end
end
