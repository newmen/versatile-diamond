module VersatileDiamond
  using Patches::RichArray

  module Concepts

    # Instance of class is refinement for environment which contain raw
    # positions of target atoms to some atoms of around specs
    class Where < Named
      include Modules::ListsComparer
      include Modules::GraphDupper
      include SpecAtomSwapper

      attr_reader :description, :parents, :specs, :links

      # Initialize an instance
      # @param [Symbol] name the name of instance
      # @param [String] description the description of instance which will be
      #   added to end of name of lateral reaction
      # @option [Array] :specs the target specific specs
      def initialize(name, description, specs: [])
        super(name)
        @description = description
        @specs = specs
        @parents = []
        @links = {}
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
        @links[target] ||= []
        @links[target] << [spec_atom, position]
      end

      # Swaps dependent specific spec
      # @param [SpecificSpec] from the spec which will be replaced
      # @param [SpecificSpec] to the spec to which swap will produce
      # TODO: rspec
      def swap_source(from, to)
        return if from == to
        return unless @specs.delete(from)
        @specs << to

        @links = dup_graph(@links) do |v|
          v.is_a?(Symbol) ? v : swap(v, from, to)
        end

        parents.each { |parent| parent.swap_source(from, to) }
      end

      # Swaps atoms
      # @param [Spec | SpecificSpec | VeiledSpec] spec the atom of which will be
      #   swapped
      # @param [Atom | AtomReference | SpecificAtom | VeiledAtom] from the used atom
      # @param [Atom | AtomReference | SpecificAtom | VeiledAtom] to the new atom
      # TODO: rspec
      def swap_atom(spec, from, to)
        return if from == to
        @links = dup_graph(@links) do |v|
          v.is_a?(Symbol) ? v : swap_only_atoms(v, from, to)
        end
      end

      # Reduce all species from current instance and from all parent instances
      # @return [Array] the result of reduce
      def all_specs
        specs + parents.reduce([]) { |acc, parent| acc + parent.all_specs }
      end

      # Concretize current instance by creating there object
      # @param [Hash] target_refs the hash of references from target name to
      #   real reactant and it atom
      # @return [There] the concretized instance as there object
      def concretize(target_refs)
        There.new(self, target_refs)
      end

      # Collect raw positions from current object and parent objects
      # @return [Array] the array of reconrds of raw_position
      def total_links
        parents.each_with_object(dup_graph(@links)) do |parent, acc|
          parent.total_links.each do |target, rels|
            acc[target] ||= []
            acc[target] += rels
          end
        end
      end

      # Gets used atoms of passed spec
      # @param [Spec | SpecificSpec] spec by which the atoms will be collected
      # @return [Array] the array of using atoms
      def used_atoms_of(spec)
        atoms = links.each_with_object([]) do |(_, rels), acc|
          rels.each { |(s, a), _| acc << a if s == spec }
        end

        atoms += parents.reduce([]) { |acc, parent| acc + parent.used_atoms_of(spec) }
        atoms.uniq
      end
    end

  end
end
