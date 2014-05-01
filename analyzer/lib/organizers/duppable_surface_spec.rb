module VersatileDiamond
  module Concepts

    # Separated functional, because it does not used in major implementation.
    # Just for testing logic
    # Role with dupping base spec ability
    module DupBaseSpecRole
      # Dups current base spec
      # @param [Sybmol] name of new spec
      # @param [Hash] atom_renames the mirror of atom keynames
      # @return [Concepts::Spec] the dupped concept base spec
      def dup(name, atom_renames)
        copy = self.class.new(name)
        copy.adsorb(self)
        atom_renames.each { |pair| copy.rename_atom(*pair) }
        copy
      end
    end

    # Accepting additional methods as role
    DuppableSurfaceSpec = SurfaceSpec.dup
    DuppableSurfaceSpec.include(DupBaseSpecRole)

  end
end
