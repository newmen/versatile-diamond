module VersatileDiamond
  module Concepts

    # Instance of class is refinement for environment which contain raw
    # positions of target atoms to some atoms of around specs
    # TODO: rspec
    class Where < Named
      # attr_reader :description, :environment

      # Initialize an instance
      # @param [Symbol] name the name of instance
      # @param [String] description the description of instance which will be
      #   added to end of name of lateral reaction
      def initialize(name, description)
        super(name)
        @description = description
        @raw_positions = {}

        # @specs = {}
      end

      # Stores raw position between target symbol and some concrete atom.
      # Position expressed by passed position variable.
      #
      # @param [Symbol] target the name of target atom
      # @param [Atom] atom the atom of some around spec
      # @param [Position] position the position between target and atom
      def raw_position(target, atom, position)
        @raw_positions[target] ||= []
        @raw_positions[target] << [atom, position]
      end

      # Adsorbs another where by merging each raw position
      # @param [Where] other an other adsorbing where
      def adsorb(other)
        other.raw_positions.each do |target, links|
          links.each { |atom, pos| raw_position(target, atom, pos) }
        end
        # dependent_from << other
      end

    #   def concretize(target_refs)
    #     ConcreteWhere.new(self, @raw_positions, target_refs)
    #   end

    #   def specs
    #     @specs.values
    #   end

    #   def dependent_from
    #     @dependent_from ||= Set.new
    #   end

    protected

      attr_reader :raw_positions

    end

  end
end
