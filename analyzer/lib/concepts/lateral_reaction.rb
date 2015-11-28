module VersatileDiamond
  module Concepts

    # Describes reaction which has a some environment expresed by there objects
    class LateralReaction < Reaction

      attr_reader :theres

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Array] theres the array of there objects
      def initialize(*super_args, theres)
        super(*super_args)
        @theres = theres
      end

      # Also changes targets of there object
      # @param [SpecificSpec] from the spec from which need to swap
      # @param [SpecificSpec] to the spec to which need to swap
      # @override
      def swap_source(from, to)
        super
        theres.each { |there| there.swap_target(from, to) }
      end

      # Also checks using in there objects
      # @param [Spec | SpecificSpec] spec the one of reactant
      # @return [Array] the array of using atoms
      # @override
      def used_atoms_of(spec)
        (super + theres.flat_map { |there| there.used_atoms_of(spec) }).uniq
      end

      # Also compare there objects
      # @param [UbiquitousReaction] other see at #super same argument
      # @return [Boolean] the same or not
      # @override
      def same?(other)
        super && lists_are_identical?(theres, other.theres, &:same?)
      end

      # Lateral reaction is lateral reaction
      # @return [Boolean] true
      def lateral?
        true
      end

      def to_s
        lateral_strs = theres.map(&:to_s)
        "#{super} : #{lateral_strs.join(' + ')}"
      end

    private

      # Also reverse there objects
      # @override
      def reverse_params
        reversed_theres = theres.map { |there| there.reverse(mapping) }
        [*super, reversed_theres]
      end

      # Also swaps target atoms for all used there objects
      # @param [SpecificSpec] spec see at #super same argument
      # @param [Atom] from see at #super same argument
      # @param [Atom] to see at #super same argument
      # @override
      def swap_atom_in_positions(spec, from, to)
        super
        theres.each { |there| there.swap_target_atom(spec, from, to) } if from != to
      end
    end

  end
end
