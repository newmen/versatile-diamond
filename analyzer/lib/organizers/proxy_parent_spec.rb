module VersatileDiamond
  module Organizers

    # Wraps not unique dependent base spec to distinguish from other similar
    class ProxyParentSpec

      # Initializes proxy instance
      # @param [DependentBaseSpec] target spec for which proxy provides
      # @param [DependentBaseSpec] child is the dependent spec which creates proxy
      #   instance
      # @param [Array] atoms of child spec which correspond to atoms of target spec
      def initialize(target, child, atoms)
        @target = target
        @child = child
        @atoms = atoms
      end

      # Compares current instance with other
      # @param [ProxyParentSpec | DependentWrappedSpec] other instance with which
      #   comparison do
      # @return [Boolean] is equal or not
      def == (other)
        other.class == self.class ? super(other) : @target == other
      end

      ['', 'clean_'].each do |prefix|
        # Counts the atom references in child spec
        # @return [Integer] the number of atom references
        define_method(:"#{prefix}relations_num") do
          @child.send("#{prefix}links").reduce(0) do |acc, (a, rs)|
            @atoms.include?(a) ? (acc + rs.size) : acc
          end
        end
      end

      # Delegates all another calls to target spec
      def method_missing(*args)
        @target.send(*args)
      end

      def inspect
        "proxy:#{@target.inspect}"
      end
    end

  end
end
