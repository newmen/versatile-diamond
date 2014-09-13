module VersatileDiamond
  module Generators
    module Code

      # Provides method that characterize the inside of specie
      module SpecieInside

        # Gets number of sceleton atoms used in specie and different from atoms of
        # parent specie
        #
        # @return [Integer] the number of atoms
        def atoms_num
          spec.target.links.size
        end

      protected

        # Delegates indexation of atom to atom sequence instance
        # @param [Concepts::Atom | Concepts::AtomRefernce | Concepts::SpecificAtom]
        #   atom which will be indexed
        # @return [Integer] an index of atom
        def index(atom)
          sequence.atom_index(atom)
        end

        # Delegates classification to atom classifier from engine code generator
        # @param [Concepts::Atom | Concepts::AtomRefernce | Concepts::SpecificAtom]
        #   atom which will be classificated
        # @return [Integer] an index of classificated atom
        def role(atom)
          generator.classifier.index(spec, atom)
        end

      private

        # Gets the parent specie classes
        # @return [Array] the array of parent specie class generators
        def parents
          spec.parents.map(&method(:specie_class))
        end

        # Delegates getting delta to atom sequence instance
        # @return [Integer] the delta of addition atoms in atom sequence
        def delta
          sequence.delta
        end

        # Gets the specie class code generator
        # @param [Organizers::DependentSpec] dept_spec dependent specie the code
        #   generator of which will be got
        # @return [Specie]
        def specie_class(dept_spec)
          generator.specie_class(dept_spec.name)
        end
      end

    end
  end
end
