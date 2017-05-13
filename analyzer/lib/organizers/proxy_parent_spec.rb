module VersatileDiamond
  module Organizers

    # Wraps not unique dependent base spec to distinguish from other similar
    class ProxyParentSpec < Tools::TransparentProxy
      include Modules::OrderProvider

      delegate :name, :spec, :links, :anchors, :specific_atoms, :relations_of
      delegate :store_child, :parents_with_twins_for

      attr_reader :child

      # Initializes proxy instance
      # @param [DependentBaseSpec] original spec for which proxy provides
      # @param [DependentBaseSpec] child is the dependent spec which creates proxy
      #   instance
      # @param [Hash] mirror of atoms from child to original
      def initialize(original, child, mirror)
        super(original)
        @child = child
        @mirror = mirror

        make_invert_mirror!
      end

      # Clones the current instance and replaces value of internal child variable and
      # also changes the mirror of child spec atoms to original spec atoms
      #
      # @param [DependentBaseSpec] other_child the new value of child variable
      # @param [Hash] mirror of old key atoms to new key atoms
      # @return [ProxyParentSpec] the clone of current instance
      def clone_with_replace_by(other_child, mirror)
        result = self.dup
        result.replace_child!(other_child, mirror)
        result
      end

      # Compares current instance with other
      # @param [ProxyParentSpec] other instance with which comparison will do
      # @return [Integer] the comparison result
      def <=>(other)
        order(other, self, :clean_relations_num) do
          order(other, self, :relations_num)
        end
      end

      # Gets the twin of passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom of child spec by which the twin in original spec will be gotten
      # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   the twin of passed atom or nil
      def twin_of(atom)
        @mirror[atom]
      end

      # Gets the atom of child spec by twin atom of original spec
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   twin by which should be gotten atom of child spec
      # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   the atom of child spec
      def atom_by(twin)
        @invert_mirror[twin]
      end

    protected

      # Replaces the value of internal child variable and change keys of internal
      # mirror variable
      #
      # @param [DependentBaseSpec] other_child see at #clone_with_replace_by same arg
      # @param [Hash] mirror see at #clone_with_replace_by same argument
      def replace_child!(other_child, mirror)
        @child = other_child
        @mirror = @mirror.each_with_object({}) do |(f, t), acc|
          acc[mirror[f]] = t
        end

        make_invert_mirror!
      end

    private

      # Makes inverted mirror
      def make_invert_mirror!
        @invert_mirror = @mirror.invert
      end

      ['', 'clean_'].each do |prefix|
        # Counts the atom references in child spec
        # @return [Integer] the number of atom references
        define_method(:"#{prefix}relations_num") do
          child_atoms = @mirror.keys
          child.send("#{prefix}links").reduce(0) do |acc, (a, rs)|
            child_atoms.include?(a) ? (acc + rs.size) : acc
          end
        end
      end
    end

  end
end
