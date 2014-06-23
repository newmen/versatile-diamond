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
          "#{@lattice_class.class_name}AtomsIterator"
        end

      private

        # Gets name of file where described lattice class
        # @return [String] the lattice class file name
        def lattice_file_name
          "#{@lattice_class.file_name}.h"
        end

        # Atoms stored in atoms directory
        # @return [String] the atoms directory
        # @override
        def additional_path
          'phases'
        end
      end

    end
  end
end
