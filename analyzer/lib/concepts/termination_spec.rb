module VersatileDiamond
  module Concepts

    # Represents a some "termination" spec which can be involved to ubiquitous
    # reaction
    # @abstract
    class TerminationSpec
      include Modules::OrderProvider

      # @return [Integer]
      def hash
        [self.class, name].hash
      end

      # Compares with an other spec
      # @param [TerminationSpec | SpecificSpec] other with which comparison
      # @return [Boolean] is specs same or not
      def ==(other)
        self.class == other.class && name == other.name
      end
      alias :eql? :==
      alias :same? :==

      # Provides the order for termination specs
      # @param [TerminationSpec] other comparing instance
      # @return [Integer] the comparing result
      def <=>(other)
        typed_order(self, other, AtomicSpec) do
          typed_order(self, other, ActiveBond) do
            comparing_core(other)
          end
        end
      end

      # @return [Boolean] true
      def termination?
        true
      end

      # Termination spec cannot belong to the gas phase
      # @return [Boolean] false
      def gas?
        false
      end

      # Termination spec isn't simple
      # @return [Boolean] false
      def simple?
        false
      end

      # Termination spec cannot be extended
      # @return [Boolean] false
      def extendable?
        false
      end

      def inspect
        "[#{name}]"
      end
    end

  end
end
