module VersatileDiamond
  module Generators
    module Code

      # Generates iterator of atoms through crystal lattice
      class LatticeAtomsIterator < CppClass
        include PolynameClass

        # Initializes generator instance
        # @param [Lattice] lattice_class for which source will be generated
        def initialize(lattice_class)
          @lattice_class = lattice_class
        end

        # Get the cpp class name
        # @return [String] the class name of atom
        def class_name
          "#{lattice_class_name}AtomsIterator"
        end

      private

        # Gets the name of lattice class
        # @return [String] the name of lattice class
        def lattice_class_name
          @lattice_class.class_name
        end

        # Gets the list of objects which headers should be included in header file
        # @return [Array] the list of including objects
        # @override
        def head_include_objects
          [@lattice_class]
        end

        # Atoms stored in atoms directory
        # @return [String] the atoms directory
        # @override
        def template_additional_path
          'phases'
        end
      end

    end
  end
end
