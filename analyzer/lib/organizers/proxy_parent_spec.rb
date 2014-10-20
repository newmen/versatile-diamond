module VersatileDiamond
  module Organizers

    # Wraps not unique dependent base spec to distinguish from other similar
    class ProxyParentSpec < Modules::TransparentProxy
      include Modules::OrderProvider

      # Initializes proxy instance
      # @param [DependentBaseSpec] original spec for which proxy provides
      # @param [DependentBaseSpec] child is the dependent spec which creates proxy
      #   instance
      # @param [Hash] mirror of atoms from child to original
      def initialize(original, child, mirror)
        super(original)
        @child = child
        @mirror = mirror
      end

      # Compares current instance with other
      # @param [ProxyParentSpec] other instance with which comparison will do
      # @return [Integer] the comparison result
      def <=> (other)
        order(other, self, :clean_relations_num) do
          order(other, self, :relations_num)
        end
      end

    private

      ['', 'clean_'].each do |prefix|
        # Counts the atom references in child spec
        # @return [Integer] the number of atom references
        define_method(:"#{prefix}relations_num") do
          child_atoms = @mirror.keys
          @child.send("#{prefix}links").reduce(0) do |acc, (a, rs)|
            child_atoms.include?(a) ? (acc + rs.size) : acc
          end
        end
      end
    end

  end
end
