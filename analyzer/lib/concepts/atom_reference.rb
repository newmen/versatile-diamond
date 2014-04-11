module VersatileDiamond
  module Concepts

    # Class describes atom referernce which contain link to some spec and link
    # to spec's atom. Behaves the same as an atom, but overrides value of
    # valence, taking into account position of the atom in structure.
    class AtomReference
      extend Forwardable

      def_delegators :@atom, :name, :lattice, :lattice=, :same?, :actives,
        :monovalents, :incoherent?, :unfixed?, :diff, :original_valence

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

      # Valence of atom with taking into account position of the atom in
      #   structure
      #
      # @return [Integer] the external valence of refered atom
      def valence
        spec.external_bonds_for(real_atom)
      end

      # Finds all relation instances for current atom in passed spec and also
      # provides relations from refered spec
      #
      # @param [Spec] spec the spec in which relations will be found, must
      #   contain current atom
      # @return [Array] the array of relations
      def relations_in(spec)
        spec.links[self] + real_atom.relations_in(@spec)
      end

      # Checks that current reference relate to some spec
      # @param [Spec] spec the checkable spec
      # @return [Boolean] is related or not?
      def reference_to?(spec)
        @spec == spec
      end

      def to_s
        "&#{@atom}"
      end

      def inspect
        to_s
      end

    private

      # Gets an atom to which references current instance
      # @param [Atom] target atom of refered spec
      def real_atom
        spec.atom(keyname)
      end
    end

  end
end
