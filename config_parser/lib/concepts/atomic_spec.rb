module VersatileDiamond
  module Concepts

    # Represents a spec which contain just one unovalence atom
    class AtomicSpec < TerminationSpec
      extend Forwardable

      # Store unovalence atom instance
      # @param [Atom] atom the atom which behaves like spec
      def initialize(atom)
        @atom = atom
      end

      def_delegators :@atom, :name, :to_s

      # def cover?(specific_spec)
      #   !specific_spec.active? && specific_spec.has_atom?(@atom)
      # end
    end

  end
end
