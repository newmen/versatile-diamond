module VersatileDiamond
  module Organizers

    # Contain some specific spec and set of dependent specs
    class DependentSpecificSpec < DependentSpec
      extend Forwardable

      attr_reader :parent

      # Initializes dependent specific spec by specific spec
      # @param [Concepts::SpecificSpec] specific_spec
      def initialize(specific_spec)
        super
        @parent = nil
        @child, @reaction, @there = nil
      end

      def_delegators :@spec, :reduced, :could_be_reduced?, :specific_atoms,
        :active_bonds_num

      # Gets name of specific spec
      # @return [Symbol] the symbol of name
      def name
        spec.respond_to?(:full_name) ? spec.full_name.to_sym : spec.name
      end

      # Gets base spec for wrapped specific spec
      # @return [Concepts::Spec] the base spec
      def base_spec
        spec.spec
      end

      # Gets name of base spec
      # @return [Symbol] the name of base spec
      def base_name
        base_spec.name
      end

      # Contain specific atoms or not
      # @return [Boolean] contain or not
      def specific?
        !specific_atoms.empty?
      end

      # Organize dependencies from another similar species. Dependencies set if
      # similar spec has less specific atoms and existed specific atoms is same
      # in both specs. Moreover, activated atoms have a greater advantage.
      #
      # @param [Hash] base_hash the cache where keys are names and values are
      #   wrapped base specs
      # @param [Array] similar_specs the array of specs where each spec has
      #   same basic spec
      def organize_dependencies!(base_cache, similar_specs)
        similar_specs = similar_specs.reject do |s|
          s == self || s.size > size
        end

        similar_specs.sort_by! { |ss| -ss.size }

        @parent = similar_specs.find do |ss|
          ss.specific_atoms.all? do |keyname, atom|
            a = specific_atoms[keyname]
            a && is?(a, atom)
          end
        end

        @parent ||= base_cache[base_name]
        @parent.store_child(self)
      end

      # Counts number of specific atoms
      # @return [Integer] the number of specific atoms
      def size
        specific_atoms.size * 8 + dangling_bonds_num * 2 + relevants_num
      end

    protected

      # Counts the sum of active bonds and monovalent atoms
      # @return [Integer] sum of dangling bonds
      def dangling_bonds_num
        active_bonds_num + monovalents_num
      end

    private

      # Counts the sum of monovalent atoms at specific atoms
      # @return [Integer] sum of monovalent atoms
      def monovalents_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.monovalents.size }
      end

      # Counts the sum of relative states of atoms
      # @return [Integer] sum of relative states
      def relevants_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.relevants.size }
      end

      # Compares two specific atoms and checks that smallest is less than
      # bigger
      #
      # @param [Concepts::SpecificAtom] bigger probably the bigger atom
      # @param [Concepts::SpecificAtom] smallest probably the smallest atom
      # @return [Boolean] smallest is less or not
      def is?(bigger, smallest)
        same_danglings?(bigger, smallest) && same_relevants?(bigger, smallest)
      end

      # Checks that smallest atom contain less dangling states than bigger
      # @param [Concepts::SpecificAtom] bigger see at #is? same argument
      # @param [Concepts::SpecificAtom] smallest see at #is? same argument
      # @return [Boolean] contain or not
      def same_danglings?(bigger, smallest)
        smallest.actives <= bigger.actives &&
          (smallest.monovalents - bigger.monovalents).empty?
      end

      # Checks that smallest atom contain less relevant states than bigger
      # @param [Concepts::SpecificAtom] bigger see at #is? same argument
      # @param [Concepts::SpecificAtom] smallest see at #is? same argument
      # @return [Boolean] contain or not
      def same_relevants?(bigger, smallest)
        diff = smallest.relevants - bigger.relevants
        diff.empty? || (diff == [:incoherent] && bigger.size > smallest.size &&
          (!bigger.monovalents.empty? || bigger.actives > 0))
      end
    end

  end
end
