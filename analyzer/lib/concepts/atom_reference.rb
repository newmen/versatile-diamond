module VersatileDiamond
  module Concepts

    # Class describes atom referernce which contain link to some spec and link
    # to spec's atom. Behaves the same as an atom, but overrides value of
    # valence, taking into account position of the atom in structure.
    class AtomReference
      extend Forwardable

      def_delegators :@atom, :name, :lattice, :lattice=, :same?, :original_same?,
        :actives, :monovalents, :incoherent?, :unfixed?, :diff, :original_valence,
        :relevants, :specific?, :closed

      attr_reader :spec, :keyname

      # Target settings
      # @param [Concepts::Spec] spec the spec on atom of which will be refered
      # @param [Symbol] atom_keyname the keyname of refered atom
      # @overload new(spec, atom_keyname)
      #   @param [Symbol] atom_keyname the keyname of refered atom
      # @overload new(spec, atom)
      #   @param [Atom | SpecificAtom] atom of passed specie
      def initialize(spec, atom_keyname)
        @spec = spec

        @original_atom =
          if atom_keyname.is_a?(Symbol)
            @keyname = atom_keyname
            spec.atom(atom_keyname)
          else
            atom_keyname
          end

        # because atom can be changed by mapping algorithm
        @atom = @original_atom.dup
      end

      # Valence of atom with taking into account position of the atom in
      #   structure
      #
      # @return [Integer] the external valence of refered atom
      def valence
        spec.external_bonds_for(@original_atom)
      end

      # Finds all relation instances for current atom in passed spec and also
      # provides relations from refered spec
      #
      # @param [Spec] spec the spec in which relations will be found, must
      #   contain current atom
      # @return [Array] the array of relations
      def relations_in(spec)
        additional_relations + (spec.links[self] || [])
      end

      # Gets relations from reference
      # @return [Array] the array of relations
      def additional_relations
        @original_atom.relations_in(spec)
      end

      def to_s
        "&#{@atom}"
      end

      def inspect
        to_s
      end
    end

  end
end
