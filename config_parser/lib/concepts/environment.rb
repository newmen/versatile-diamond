module VersatileDiamond
  module Concepts

    # Instance of class represet some environment around reactant atoms aliases
    # of which defined by targets setup
    class Environment < Named

      # Special exception for case when target references isn't valid
      class InvalidTarget < Exception
        attr_reader :target
        def initialize(target); @target = target end
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

      # Checks passed target references and if they is valid then creates new
      # lateral instance
      #
      # @param [Hash] target_refs the hash where keys is target names from
      #   current environment and values is real atoms of reactants
      # @raise [InvalidTarget] when some of target references is wrong
      # @result [Lateral] new lateral instance
      def make_lateral(**target_refs)
        validated_refs = @targets.each_with_object({}) do |name, hash|
          atom = target_refs.delete(name)
          raise InvalidTarget.new(name) if !atom || hash[name]
          hash[name] = atom
        end
        target_refs.keys.each { |name| raise InvalidTarget.new(name) }
        Lateral.new(name, validated_refs)
      end
    end

  end
end
