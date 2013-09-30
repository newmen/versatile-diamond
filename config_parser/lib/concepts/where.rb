module VersatileDiamond
  module Concepts

    # Instance of class is refinement for environment which contain raw
    # positions of target atoms to some atoms of around specs
    class Where < Named
      include Visitors::Visitable
      include SpecAtomSwapper

      attr_reader :description, :parents, :specs

      # Initialize an instance
      # @param [Symbol] name the name of instance
      # @param [String] description the description of instance which will be
      #   added to end of name of lateral reaction
      # @option [Array] :specs the target specific specs
      def initialize(name, description, specs: [])
        super(name)
        @description = description
        @raw_positions = []
        @specs = specs # the used specific species
        @parents = [] # the parent where objects
      end

      # Stores raw position between target symbol and some concrete atom.
      # Position expressed by passed position variable.
      #
      # @param [Symbol] target the name of target atom
      # @param [Array] spec_atom the array where first item is specific spec
      #   and second item is atom of it specific spec
      # @param [Position] position the position between target and atom
      # TODO: rspec
      def raw_position(target, spec_atom, position)
        @raw_positions << [target, spec_atom, position]
      end

      # Swaps dependent specific spec
      # @param [SpecificSpec] from the spec which will be replaced
      # @param [SpecificSpec] to the spec to which swap will produce
      def swap_source(from, to)
        return if from == to
        return unless @specs.delete(from)
        @specs << to

        raw_positions.each { |_, spec_atom, _| swap(spec_atom, from, to) }
        parents.each { |parent| parent.swap_source(from, to) }
      end

      # Reduce all species from current instance and from all parent instances
      # @return [Array] the result of reduce
      def all_specs
        specs + parents_reduce(:all_specs)
      end

      # Concretize current instance by creating there object
      # @param [Hash] target_refs the hash of references from target name to
      #   real reactant and it atom
      # @return [There] the concretized instance as there object
      def concretize(target_refs)
        raw_positions = @raw_positions + parents_reduce(:raw_positions)
        positions = raw_positions.each_with_object({}) do |arr, hash|
          target, env_spec_atom, position = arr
          target_spec_atom = target_refs[target]

          hash[target_spec_atom] ||= []
          hash[target_spec_atom] << [env_spec_atom, position]
        end

        There.new(self, positions)
      end

      # Also visit base spec that belongs to self
      # @param [Visitors::Visitor] visitor the object that will accumulate
      #   state of current object
      def visit(visitor)
        super
        specs.each { |spec| spec.visit(visitor) }
      end

    protected

      attr_reader :raw_positions

    private

      # Reduces values of parents by method name
      # @param [Symbol] method the method name
      # @return [Array] the array with reduced values
      def parents_reduce(method)
        parents.reduce([]) { |acc, parent| acc + parent.send(method) }
      end
    end

  end
end
