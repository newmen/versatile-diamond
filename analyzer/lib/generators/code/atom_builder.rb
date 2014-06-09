module VersatileDiamond
  module Generators
    module Code

      # Creates AtomBuilder class
      class AtomBuilder < CppClassWithGen
        extend Forwardable

        # Also initialize internal atoms_mirror hash
        # @param [Array] args see at #super arguments
        # @override
        def initialize(*args)
          super

          @atoms_mirror = Hash[pure_atoms.map(&:name).zip(pure_atoms)]
        end

      private

        # Deligates getting collection of unique pure atoms
        # @return [Array] the uniq pure atoms
        def pure_atoms
          @generator.unique_pure_atoms
        end

        # Collects all possible combinations of atom name and lattice
        # @return [Array] the list of all combinations
        def combinations
          pairs_set = @generator.classifier.props.reduce(Set.new) do |acc, prop|
            acc << [prop.atom_name, prop.lattice]
          end

          pairs_set.to_a.map do |atom_name, lattice|
            [@atoms_mirror[atom_name], lattice]
          end
        end

        # Build method name
        # @param [Atom] atom_class the atom generation class instance
        # @param [Concepts::Lattice] lattice the atom belongs to this lattice
        # @return [String] the method name
        def method_name(atom_class, lattice)
          lattice_name = lattice && lattice.name
          "build#{atom_class.class_name}#{lattice_name}"
        end

        # Gets name of file which will be generated
        # @return [String] the name of result file without extention
        def file_name
          template_name
        end

        # Atoms stored in atoms directory
        # @return [String] the atoms directory
        # @override
        def additional_path
          'atoms'
        end
      end

    end
  end
end
