module VersatileDiamond
  using Patches::RichArray

  module Concepts

    # Instance of class is refinement for environment which contain raw
    # positions of target atoms to some atoms of around specs
    class Where < Named
      include Modules::ListsComparer
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

        @raw_positions = @raw_positions.map do |target, spec_atom, position|
          [target, swap(spec_atom, from, to), position]
        end
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
        positions = total_raw_positions.each_with_object({}) do |arr, hash|
          target, env_spec_atom, position = arr
          target_spec_atom = target_refs[target]

          hash[target_spec_atom] ||= []
          hash[target_spec_atom] << [env_spec_atom, position]
        end

        There.new(self, positions)
      end

      # Compares raw positions between self and other where objects
      # @param [Where] other where object which raw positions will be checked
      # @return [Boolean] are same raw positions or not
      # TODO: valid comparison?
      def same_positions?(other)
        return false unless same_specs?(other)

        orp = other.raw_positions.dup
        raw_positions.all? do |target, spec_atom, position|
          orp.delete_one do |t, sa, p|
            t == target && p == position && same_spec_atoms?(spec_atom, sa)
          end
        end
      end

    protected

      attr_reader :raw_positions

      # Collect raw positions from current object and parent objects
      # @return [Array] the array of reconrds of raw_position
      def total_raw_positions
        raw_positions + parents_reduce(:raw_positions)
      end

    private

      # Reduces values of parents by method name
      # @param [Symbol] method the method name
      # @return [Array] the array with reduced values
      def parents_reduce(method)
        parents.reduce([]) { |acc, parent| acc + parent.send(method) }
      end

      # Compares specs of current and other where objects
      # @param [Where] other where object which specs will be checked
      # @return [Boolean] are same specs or not
      def same_specs?(other)
        lists_are_identical?(specs, other.specs, &:same?)
      end

      # Compares two spec_atom instances
      # @param [Array] first spec_atom instance
      # @param [Array] second spec_atom instance
      # @return [Boolean] are identical spec_atom instances or not
      def same_spec_atoms?(first, second)
        sf, ss = first.first, second.first
        return false unless sf.links.size == ss.links.size

        args = [sf, ss, { collaps_multi_bond: true }]
        insecs = Mcs::SpeciesComparator.intersec(*args)
        return false unless sf.links.size == insecs.first.size

        af, as = first.last, second.last
        insecs.any? do |intersec|
          intersec.any? { |f, t| f == af && t == as }
        end
      end
    end

  end
end
