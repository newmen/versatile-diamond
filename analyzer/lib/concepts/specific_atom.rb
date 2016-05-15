module VersatileDiamond
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
      class AlreadyUnfixed; end

      def_delegators :@atom, :name, :lattice, :lattice=, :original_valence,
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
          atom.same?(other.atom) &&
            lists_are_identical?(options, other.options) &&
            lists_are_identical?(monovalents, other.monovalents)
        elsif other.is_a?(VeiledAtom)
          other.same?(self)
        else
          options.empty? && monovalents.empty? && atom.same?(other)
        end
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
        if unfixed?
          raise AlreadyUnfixed.new
          not_unfixed!
        end
        @options << Incoherent.property
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
        other.relevants - relevants
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
    end

  end
end
