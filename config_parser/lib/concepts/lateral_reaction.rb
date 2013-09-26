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

      # Also counts sizes of there objects
      # @return [Float] the number of used atoms
      def size
        super + @theres.map(&:size).reduce(:+)
      end

      # Also visit there objects
      # @param [Visitors::Visitor] visitor see at #super same argument
      # @override
      def visit(visitor)
        super
        @theres.each { |there| there.visit(visitor) }
      end

      # Collects and return all where object for visitor
      # @return [Array] the array of where objects
      def wheres
        @theres.reduce([]) { |acc, there| acc << there.where }
      end

    private

      # Also reverse there objects
      # @override
      def reverse_params
        reversed_theres = theres.map do |there|

        end
        [*super, reversed_theres]
      end

      # Compares with other lateral reaction by calling the #same? method from
      # superclass and comparing theres collections
      #
      # @param [LateralReaction] other with which comparison
      # @yield [There, There] condition for comparison
      # @return [Boolean] is reaction initially similar, and the condition is
      #   met for both theres collections
      def compare_with_other(other, &block)
        # calling the .same? method from superclass
        self.class.superclass.instance_method(:same?).bind(self).call(other) &&
          lists_are_identical?(theres, other.theres, &block)
      end
    end

  end
end
