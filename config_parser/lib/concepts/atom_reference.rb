module VersatileDiamond
  module Concepts

    # Class describes atom referernce which contain link to some spec and link
    # to spec's atom. Behaves the same as an atom, but overrides value of
    # valence, taking into account position of the atom in structure.
    class AtomReference
      extend Forwardable

      # attr_reader :spec, :atom

      # Target setting
      # @param [Concepts::Spec] spec the spec on atom of which will be refered
      # @param [Symbol] atom_keyname the keyname of refered atom
      def initialize(spec, atom_keyname)
        @spec = spec
        @atom = @spec.atom(atom_keyname)
      end

      def_delegators :@atom, :lattice #, :same?, :diff

      # Valence of atom with taking into account position of the atom in
      #   structure
      #
      # @return [Integer] the external valence of refered atom
      def valence
        @spec.external_bonds_for(@atom)
      end

      def to_s
        "&#{@atom}"
      end
    end

  end
end
