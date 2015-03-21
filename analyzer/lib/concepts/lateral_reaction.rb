module VersatileDiamond
  module Concepts

    # Describes reaction which has a some environment expresed by there objects
    class LateralReaction < Reaction

      # Raises when target atom of sidepiece there object haven't lattice
      class ReversingError < Errors::Base
        attr_reader :spec
        def initialize(spec, atom)
          @spec = spec
          @atom = atom
        end

        # Gets the keyname of invalid atom
        # @return [Symbol] the keyname of atom
        def keyname
          @spec.keyname(@atom)
        end
      end

      attr_reader :theres

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Array] theres the array of there objects
      def initialize(*super_args, theres)
        super(*super_args)
        @theres = theres
      end

      # Also checks using in there objects
      # @param [Spec | SpecificSpec] spec the one of reactant
      # @return [Array] the array of using atoms
      def used_atoms_of(spec)
        (super + theres.flat_map { |there| there.used_atoms_of(spec) }).uniq
      end

      # Also compare there objects
      # @param [UbiqutousReaction] other see at #super same argument
      # @return [Boolean] the same or not
      # @override
      def same?(other)
        self.class == other.class ? all_same?(other) : false
      end

      # Checks that current reaction covered by other reaction
      # @param [LateralReaction] other the comparable reaction
      # @return [Boolean] covered or not
      def cover?(other)
        super_same?(other) && theres.all? do |there|
          other.theres.any? { |t| there.same?(t) || there.cover?(t) }
        end
      end

      def to_s
        lateral_strs = theres.map(&:to_s)
        "#{super} : #{lateral_strs.join(' + ')}"
      end

    private

      # Also reverse there objects
      # @override
      def reverse_params
        reversed_theres = theres.map do |there|
          reversed_refs = {}
          there.target_refs.each do |target, (spec, atom)|
            other_side_spec_atom = mapping.other_side(spec, atom)
            if other_side_spec_atom.last.lattice
              reversed_refs[target] = other_side_spec_atom
            else
              raise ReversingError.new(*other_side_spec_atom)
            end
          end

          There.new(there.where, reversed_refs)
        end

        [*super, reversed_theres]
      end

      # Calls the #same? method from superclass
      # @param [LateralReaction] other the comparable lateral reaction
      # @return [Boolean] same by super or not
      def super_same?(other)
        self.class.superclass.instance_method(:same?).bind(self).call(other)
      end

      # Are another reaction completely same
      # @param [LateralReaction] other with which comparison
      # @return [Boolean] is reaction initially similar, and all theres are same
      def all_same?(other)
        super_same?(other) && lists_are_identical?(theres, other.theres, &:same?)
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
