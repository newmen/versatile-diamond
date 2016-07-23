module VersatileDiamond
  module Generators
    module Code

      # Creates Atom class
      class Atom < CppClass
        include PolynameClass
        extend Forwardable

        def_delegators :@atom, :name, :valence

        # Initializes by concept atom
        # @param [Concepts::Atom] atom as element of Mendeleev's table
        def initialize(atom)
          @atom = atom
        end

        # Get the cpp class name
        # @return [String] the class name of atom
        def class_name
          name.to_s
        end

      private

        # The list of common files which are used by atom class generator
        # @return [Array] the list with specific atom class file item
        def using_common_files
          head_include_objects
        end

        # Gets the list of objects which headers should be included in header file
        # of current class
        #
        # @return [Array] the list of including objects
        # @override
        def head_include_objects
          [common_file('specified_atom')]
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
