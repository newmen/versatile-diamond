module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Lattice class
      class Lattice < CppClassWithGen
        extend Forwardable

        def_delegators :@lattice, :default_surface_height

        # Initializes by concept lattice
        # @param [Concepts::Lattice] lattice as element of Mendeleev's table
        # @param [Organizers::AtomClassifier] classifier of atom properties
        def initialize(lattice, classifier)
          @lattice = lattice
          @classifier = classifier
        end

        # Also copies relations cpp template class which own for each lattice
        # @param [String] see at #super same argument
        def generate(root_dir)
          super
          FileUtils.cp(src_relations_file_path, dst_relations_file_path(root_dir))
        end

        # Get the cpp class name
        # @return [String] the class name of atom
        def class_name
          instance.class.to_s
        end

      private

        def_delegator :@lattice, :instance

        # The name of lattice relations code instance
        # @return [String] the relations underscored instance name
        def relations_name
          "#{class_name.underscore}_relations"
        end

        # The class name of lattice relations code instance
        # @return [String] the class name of used relations
        def relations_class_name
          relations_name.classify
        end

        # The file name of lattice relations code instance
        # @return [String] the file name of used relations
        def relations_file_name
          "#{relations_name}.h"
        end

        # The source file path to relations header file
        # @return [Pathname] the path to source relations file
        def src_relations_file_path
          template_dir + relations_file_name
        end

        # The destination file path to relations header file
        # @return [Pathname] the path to result relations file
        def dst_relations_file_path(root_dir)
          out_dir(root_dir) + relations_file_name
        end

        # Name of method for binding each pair of atoms
        # @return [String] the method name used in binding process
        def binding_relation_method
          bond = instance.connecting_bond
          "{bond.dir}_#{bond.face}"
        end

        # Combines sequence of periods between atoms in crystal lattice
        # where first X, second Y, and last Z
        # @return [String] the periods joined through coma
        def periods_sequence
          instance.periods.to_a.sort(&:first).map(&:last).map(&:to_s).join(', ')
        end

        # Finds index of atom properties that correspond to major atom instance of
        # crystal lattice
        #
        # @return [Integer] see at #crystal_atom_index result
        def major_atom_index
          crystal_atom_index(instance.major_crystal_atom)
        end

        # Gets surface atom which configured through DSL
        # @return [Integer] see at #crystal_atom_index result
        def surface_atom_index
          crystal_atom_index(instance.surface_crystal_atom)
        end

        # Finds the crystal atom index by atom information hash
        # @param [Hash] info about crystal atom
        # @return [Integer] the index of classified atom properties that correspond to
        #   target atom info
        def crystal_atom_index(info)
          full_info = info.dup
          full_info[:lattice] = @lattice
          target = @classifier.props.find { |prop| prop.correspond?(full_info) }

          raise 'Used crystal atom was not found!' unless target
          @classifier.index(target)
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
