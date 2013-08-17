module VersatileDiamond
  module Concepts

    # Instance of class represet some environment around reactant atoms aliases
    # of which defined by targets setup
    # TODO: rspec
    class Environment < Named
      def initialize(name)
        super
        @wheres = {}
      end

      # Store aliased names for target atoms
      # @param [Array] names the aliased names of target atoms
      def targets=(names)
        @targets = names
      end

      # Checks passed name for current target
      # @param [Symbol] name the name of one of targets
      # @return [Boolean] it is target or not
      def is_target?(name)
        @targets && @targets.include?(name)
      end

      # def resolv_alias(name)
      #   @aliases && @aliases[name]
      # end
    end

  end
end
