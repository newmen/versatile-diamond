module VersatileDiamond

  module Concepts

    class AtomicSpec < TerminationSpec
      include Modules::SyntaxChecker

      def initialize(atom_name)
        @atom = Atom[atom_name]
        syntax_error('.invalid_valence') if @atom.valence != 1
      end

      def name
        @atom.name
      end

      def external_bonds
        @atom.valence
      end

      def to_s
        @atom.to_s
      end

      def cover?(specific_spec)
        !specific_spec.active? && specific_spec.has_atom?(@atom)
      end
    end

  end

end
