module VersatileDiamond
  module Concepts

    # Instance of class is refinement for environment which contain raw
    # positions of target atoms to some atoms of around specs
    class Where < Named
      include Visitors::Visitable

      attr_reader :specs, :description #, :environment

      # Initialize an instance
      # @param [Symbol] name the name of instance
      # @param [String] description the description of instance which will be
      #   added to end of name of lateral reaction
      # @option [Array] :specs the target specific specs
      def initialize(name, description, specs: [])
        super(name)
        @description = description
        @raw_positions = {}
        @specs = specs
      end

      # Stores raw position between target symbol and some concrete atom.
      # Position expressed by passed position variable.
      #
      # @param [Symbol] target the name of target atom
      # @param [Atom] atom the atom of some around spec
      # @param [Position] position the position between target and atom
      # TODO: rspec
      def raw_position(target, atom, position)
        @raw_positions[target] ||= []
        @raw_positions[target] << [atom, position]
      end

      # Gets a parents (position of which is adsorbed) of current where object
      # @return [Array] the array of parents
      def parents
        @parents ||= []
      end

      # Concretize current instance by creating there object
      # @param [Hash] target_refs the hash of references from target names to
      #   real reactant atoms
      # @return [There] the concretized instance as there object
      def concretize(target_refs)
        positions = raw_positions.each_with_object({}) do |(name, link), hash|
          atom = target_refs[name]
          hash[atom] = link
        end

        There.new(self, positions)
      end

      # Also visit base spec that belongs to self
      # @param [Visitors::Visitor] visitor the object that will accumulate
      #   state of current object
      def visit(visitor)
        super
        @specs.each { |spec| spec.visit(visitor) }
      end

    protected

      attr_reader :raw_positions

    end

  end
end
