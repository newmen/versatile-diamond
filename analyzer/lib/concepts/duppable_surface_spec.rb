module VersatileDiamond
  module Concepts

    # Separated functional, because it does not used in major implementation.
    # Just for testing logic
    class DuppableSurfaceSpec < SurfaceSpec
      # Dups current base spec
      # @param [Sybmol] name of new spec
      # @param [Hash] atom_renames the mirror of atom keynames
      # @return [Spec] the dupped concept base spec
      def dup(name, atom_renames)
        copy = self.class.new(name)
        copy.adsorb(self)
        atom_renames.each { |pair| copy.rename_atom(*pair) }
        copy
      end

      # Disguises as original class name
      # @return [Class] the surface spec class
      def class
        SurfaceSpec
      end
    end
  end
end
