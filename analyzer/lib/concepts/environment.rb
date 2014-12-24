module VersatileDiamond
  module Concepts

    # Instance of class represet some environment around reactant atoms aliases
    # of which defined by targets setup
    class Environment < Named

      # Initialize new environment instance
      # @param [Symbol] name see at #super same argument
      # @option [Array] :targets the target atom aliases
      def initialize(name, targets: [])
        super(name)
        @targets = targets
      end

      # Stores aliased names for target atoms
      # @param [Array] names the aliased names of target atoms
      def targets=(names)
        @targets = names
      end

      # Checks passed name for current target
      # @param [Symbol] name the name of one of targets
      # @return [Boolean] it is target or not
      def target?(name)
        @targets.include?(name)
      end

      # Checks passed target references and if they is valid then creates new
      # lateral instance
      #
      # @param [Hash] target_refs the hash where keys is target names from
      #   current environment and values is array of real spec and their atom
      # @result [Lateral] new lateral instance
      def make_lateral(**target_refs)
        Lateral.new(name, target_refs)
      end
    end

  end
end
