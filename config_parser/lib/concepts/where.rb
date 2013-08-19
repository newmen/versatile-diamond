module VersatileDiamond
  module Concepts

    # Instance of class is refinement for environment which contain raw
    # positions of target atoms to some atoms of around specs
    class Where < Named
      attr_reader :specs, :description #, :environment

      # Initialize an instance
      # @param [Symbol] name the name of instance
      # @param [String] description the description of instance which will be
      #   added to end of name of lateral reaction
      # @option [Array] :specs the target specific specs
      def initialize(name, description, specs: Set.new)
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

      # Adsorbs another where by merging each raw position
      # @param [Where] other an other adsorbing where
      # TODO: rspec
      def adsorb(other)
        other.raw_positions.each do |target, links|
          links.each { |atom, pos| raw_position(target, atom, pos) }
        end
        # dependent_from << other
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

    #   def dependent_from
    #     @dependent_from ||= Set.new
    #   end

    protected

      attr_reader :raw_positions

    end

  end
end
