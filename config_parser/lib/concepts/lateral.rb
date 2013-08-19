module VersatileDiamond
  module Concepts

    # The instance of class stores references from target names to real atoms
    # of reactants
    # TODO: rspec
    class Lateral < Named

      # Initialize an instance of class and checks target references for
      # validation
      #
      # @param [Symbol] name the name of instance, same as name of environment
      # @param [Hash] target_refs the hash where keys is target names from
      #   environment and values is real atoms of reactants
      def initialize(name, target_refs)
        super(name)
        @target_refs = target_refs
      end

      # Concretize passed where by target references
      # @param [Where] where the where which will be concretized
      # @return [There] concretized where as there object
      def there(where)
        where.concretize(@target_refs)
      end
    end

  end
end
