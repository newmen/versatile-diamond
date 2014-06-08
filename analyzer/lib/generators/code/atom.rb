module VersatileDiamond
  module Generators
    module Code

      # Creates Atom class
      class Atom < CppClass
        extend Forwardable

        def_delegator :@atom, :valence

        # Initializes by concept atom
        # @param [Concepts::Atom] atom as element of Mendeleev's table
        def initialize(atom)
          @atom = atom
        end

      private

        # Get the cpp class name
        # @return [String] the class name of atom
        def class_name
          @atom.name
        end

        # Gets the result file name
        # @return [String] the result file name of atom class
        def file_name
          class_name.downcase
        end

        # Gets define name
        # @return [String] the inclusion warden name
        def define_name
          "#{class_name.upcase}_H"
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
