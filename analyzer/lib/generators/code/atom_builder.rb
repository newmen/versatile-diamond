module VersatileDiamond
  module Generators
    module Code

      # Creates AtomBuilder class
      class AtomBuilder < CppClassWithGen
        class << self
          # Gets method name for passed atom
          # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
          #   atom for which the builder method name will be gotten
          # @return [String] the name of method which will build the atom under
          #   simulation
          def method_for(atom)
            method_name(Atom.new(atom), atom.lattice)
          end

          # Build method name
          # @param [Atom] atom_class the atom generation class instance
          # @param [Concepts::Lattice] lattice the atom belongs to this lattice
          # @return [String] the method name
          def method_name(atom_class, lattice)
            lattice_name_with_prefix = lattice ? "_#{lattice.name}" : ''
            "build#{atom_class.class_name}#{lattice_name_with_prefix}"
          end
        end

        # Also initialize internal atoms_mirror hash
        # @param [EngineCode] generator see at #super same arguments
        # @override
        def initialize(generator)
          super
          @pure_atoms = generator.unique_pure_atoms
          @atoms_mirror = Hash[@pure_atoms.map(&:name).zip(@pure_atoms)]
        end

      private

        # Collects all possible combinations of atom name and lattice
        # @return [Array] the list of all combinations
        def combinations
          pairs_set = generator.classifier.props.reduce(Set.new) do |acc, prop|
            acc << [prop.atom_name, prop.lattice]
          end

          pairs_set.to_a.map do |atom_name, lattice|
            [@atoms_mirror[atom_name], lattice]
          end
        end

        # Delegates call to static method
        # @param [Array] args which will passed to static method
        # @return [String] the method name
        def method_name(*args)
          self.class.method_name(*args)
        end

        # Gets the list of atoms which headers should be included in header file
        # @return [Array] the list of including objects
        # @override
        def head_include_objects
          @pure_atoms
        end

        # Atoms stored in atoms directory
        # @return [String] the atoms directory
        # @override
        def template_additional_path
          'atoms'
        end
      end

    end
  end
end
