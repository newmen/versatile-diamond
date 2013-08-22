module VersatileDiamond
  module Concepts

    # Class describes atom referernce which contain link to some spec and link
    # to spec's atom. Behaves the same as an atom, but overrides value of
    # valence, taking into account position of the atom in structure.
    class AtomReference
      extend Forwardable

      attr_reader :spec, :keyname

      # Target settings
      # @param [Concepts::Spec] spec the spec on atom of which will be refered
      # @param [Symbol] atom_keyname the keyname of refered atom
      def initialize(spec, atom_keyname)
        @spec = spec
        @keyname = atom_keyname
        @atom = @spec.atom(atom_keyname).dup # because atom can be changed by
        # mapping algorithm
      end

      def_delegators :@atom, :lattice, :lattice=, :same?, :diff

      # Valence of atom with taking into account position of the atom in
      #   structure
      #
      # @return [Integer] the external valence of refered atom
      def valence
        real_atom = @spec.atom(@keyname)
        @spec.external_bonds_for(real_atom)
      end

      def to_s
        "&#{@atom}"
      end
    end

  end
end
