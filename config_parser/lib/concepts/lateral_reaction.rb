module VersatileDiamond
  module Concepts

    # Describes reaction which has a some environment expresed by there objects
    class LateralReaction < Reaction

      attr_reader :theres

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Array] atoms_map the atom-mapping result
      def initialize(*super_args, theres)
        super(*super_args)
        @theres = theres
      end

      # Also compare there objects
      # @param [UbiqutousReaction] other see at #super same argument
      # @return [Boolean] the same or not
      # @override
      def same?(other)
        if self.class == other.class
          compare_with_other(other) { |t1, t2| t1.same?(t2) }
        else
          false
        end
      end

      # Organize dependencies from another lateral reactions
      # @param [Array] lateral_reactions the possible children
      # @override
      def organize_dependencies!(lateral_reactions)
        lateral_reactions.each do |reaction|
          next if reaction == self
          next unless compare_with_other(reaction) do |self_t, other_t|
            self_t.cover?(other_t)
          end

          more_complex << reaction
        end
      end

    private

      # Also reverse there objects
      # @override
      def reverse_params
        [*super, @theres] # TODO: rebind to another atoms
      end

      # def accept_self(visitor)
      #   @theres.each { |where| where.visit(visitor) }
      #   visitor.accept_lateral_equation(self)
      # end

      # Compares with other lateral reaction by calling the #same? method from
      # superclass and comparing theres collections
      #
      # @param [LateralReaction] other with which comparison
      # @yield [There, There] condition for comparison
      # @return [Boolean] is reaction initially similar, and the condition is
      #   met for both theres collections
      def compare_with_other(other, &block)
        # calling a .same? method from superclass
        self.class.superclass.instance_method(:same?).bind(self).call(other) &&
          lists_are_identical?(theres, other.theres, &block)
      end
    end

  end
end
