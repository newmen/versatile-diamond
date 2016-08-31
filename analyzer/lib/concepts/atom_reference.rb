module VersatileDiamond
  module Concepts

    # Class describes atom referernce which contain link to some spec and link
    # to spec's atom. Behaves the same as an atom, but overrides value of
    # valence, taking into account position of the atom in structure.
    class AtomReference
      include Modules::ListsComparer
      extend Forwardable

      def_delegators :@atom, :name, :lattice, :lattice=, :same?, :original_same?,
        :actives, :monovalents, :incoherent?, :unfixed?, :diff, :original_valence,
        :relevants, :specific?, :relations_limits

      attr_reader :spec, :keyname

      # Target settings
      # @param [Spec] spec on atom of which the current instance will be refered
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

      # Duplicates passed instance
      # @param [AtomReference] ref the atom reference which will be duplicated
      def initialize_copy(ref)
        @spec = ref.spec
        @keyname = ref.keyname
        @original_atom = ref.original_atom
        @atom = ref.atom.dup
      end

      # @param [Atom | AtomReference | SpecificAtom] other comparing atom
      # @return [Boolean] are accurate same atoms or not
      def accurate_same?(other)
        (self.class == other.class && valence == other.valence &&
                  lists_are_identical?(using_relations, other.using_relations) &&
                  atom.accurate_same?(other.atom)) ||
          (other.is_a?(VeiledAtom) && accurate_same?(other.original))
      end

      # Atom reference always is reference
      # @return [Boolean] true
      def reference?
        true
      end

      # Valence of atom with taking into account position of the atom in
      #   structure
      #
      # @return [Integer] the external valence of refered atom
      def valence
        spec.external_bonds_for(@original_atom)
      end

      # @return [Atom] self instance without specific states
      def clean
        self
      end

      # Gets relations from reference
      # @return [Array] the array of relations
      def additional_relations
        spec.links[original_atom].map { |a, r| [a.dup, r] }
      end

      def to_s
        "&#{atom}"
      end

      def inspect
        to_s
      end

    protected

      attr_reader :atom, :original_atom

      # @return [Array] the list of using relations
      def using_relations
        additional_relations.map(&:last)
      end
    end

  end
end
