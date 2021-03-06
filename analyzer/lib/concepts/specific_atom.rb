module VersatileDiamond
  using Patches::RichArray

  module Concepts

    # Specified atom class, contain additional atom states like incoherentness,
    # unfixness and activeness
    class SpecificAtom
      include Modules::ListsComparer
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

      # Error for case if unfixed state is stated but incoherent state states now
      class AlreadyUnfixed < Errors::Base; end

      def_delegators :atom, :name, :lattice, :lattice=, :original_valence,
        :original_same?, :reference?, :relations_limits

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
        @options = ancestor ? ancestor.options.dup : options
        @monovalents = ancestor ? ancestor.monovalents.dup : monovalents
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
        atom.valence - actives - monovalents.size
      end

      # Gets the unspecified atom instance
      # @return [Atom | AtomReference] without specific states
      def clean
        atom
      end

      # Specific atom could be not specified
      # @return [Boolean] is specified or not
      def specific?
        !(options.empty? && monovalents.empty?)
      end

      # Compares current instance with other
      # @param [Atom | AtomReference | SpecificAtom] other the other atom with
      #   which comparing do
      # @return [Boolean] is the same atom or not
      def same?(other)
        if self.class == other.class
          atom.same?(other.atom) && equal_properties?(other)
        elsif other.is_a?(VeiledAtom)
          other.same?(self)
        else
          options.empty? && monovalents.empty? && atom.same?(other)
        end
      end

      # @param [Atom | AtomReference | SpecificAtom] other comparing atom
      # @return [Boolean] are accurate same atoms or not
      def accurate_same?(other)
        (self.class == other.class &&
                  atom.accurate_same?(other.atom) && equal_properties?(other)) ||
          (other.is_a?(VeiledAtom) && accurate_same?(other.original))
      end

      # Setup monovalent atom for using it
      # @param [Atom] atom the monovalent atom which is used as one of bond
      def use!(atom)
        @monovalents << AtomicSpec.new(atom)
      end

      # Activates atom instance
      def active!
        @options << ActiveBond.property
      end

      # Changes atom incoherent state
      # @raise [AlreadyStated] if atom already has incoherent state
      def incoherent!
        raise AlreadyStated.new('incoherent') if incoherent?
        is_unfixed = unfixed?
        not_unfixed! if is_unfixed
        @options << Incoherent.property
        raise AlreadyUnfixed.new if is_unfixed
      end

      # Changes atom unfixed state
      # @raise [AlreadyStated] if atom already has unfixed state
      def unfixed!
        raise AlreadyStated.new('unfixed') if incoherent? || unfixed?
        @options << Unfixed.property
      end

      [Incoherent, Unfixed].each do |klass|
        state = klass.to_s.split('::').last.downcase
        relevant_property = klass.property
        # Defines methods for checking atom state
        # @return [Boolean] is atom has state or not
        define_method(:"#{state}?") do
          options.include?(relevant_property)
        end

        # Defines methods for unsetup atom state
        # @raise [NotStated] if atom doesn't have target state
        define_method(:"not_#{state}!") do
          raise NotStated.new(state) unless send(:"#{state}?")
          options.delete(relevant_property)
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
        actives_delta = actives - other.actives
        actives_delta = 0 if actives_delta < 0
        (other.relevants - relevants) +
          monovalents.accurate_diff(other.monovalents) +
          ([ActiveBond.property] * actives_delta)
      end

      # Applies diff to current options
      # @param [Array] diff the array which contain adsorbing states
      def apply_diff(diff)
        diff.each { |property| property.apply_to(self) }
      end

      # Gets only relevant states
      # @return [Array] the array of relevant states
      def relevants
        opts_without_actives = options.dup
        opts_without_actives.delete(ActiveBond.property)
        (opts_without_actives + atom.relevants).uniq
      end

      # Provides additional valence states of current atom
      # @return [Array] the array of relations
      def additional_relations
        own_links = (options + monovalents).map { |state| [self, state] }
        atom.additional_relations + own_links
      end

      def to_s
        chars = (options + monovalents).map(&:to_s)
        "#{atom}[#{chars.sort.join(', ')}]"
      end

      def inspect
        to_s
      end

    protected

      attr_reader :atom, :options

    private

      # Selects from options only active bonds
      # @return [Array] array of active bonds
      def active_options
        active_bond = ActiveBond.property
        options.select { |o| o == active_bond }
      end

      # @return [Boolean] are equal properties of self and other atoms or not
      def equal_properties?(other)
        lists_are_identical?(options, other.options) &&
          lists_are_identical?(monovalents, other.monovalents)
      end
    end

  end
end
