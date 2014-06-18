module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Lattice class
      class Lattice < CppClass
        include PolynameClass
        extend Forwardable

        def_delegators :instance, :default_surface_height

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
          cp_crystal_properties_file_path(root_dir)
          cp_relations_file_path(root_dir)
          LatticeAtomsIterator.new(self).generate(root_dir)
        end

        # Get the cpp class name
        # @return [String] the class name of atom
        def class_name
          instance.class.to_s
        end

      private

        def_delegator :@lattice, :instance

        %w(crystal_properties relations).each do |name|
          name_method = :"#{name}_name"
          file_name_method = :"#{name}_file_name"

          # The name of lattice #{name} code instance
          # @return [String] the #{name} underscored instance name
          define_method(name_method) do
            "#{class_name.underscore}_#{name}"
          end

          # The class name of lattice #{name} code instance
          # @return [String] the class name of used #{name}
          define_method(:"#{name}_class_name") do
            send(name_method).classify
          end

          # The file name of lattice #{name} code instance
          # @return [String] the file name of used #{name}
          define_method(file_name_method) do
            "#{send(name_method)}.h"
          end

          # The source file path to #{name} header file
          # @return [Pathname] the path to source #{name} file
          define_method(:"src_#{name}_file_path") do
            template_dir + send(file_name_method)
          end

          # The destination file path to #{name} header file
          # @param [String] root_dir the directory of generation results
          # @return [Pathname] the path to result #{name} file
          define_method(:"dst_#{name}_file_path") do |root_dir|
            out_dir(root_dir) + send(file_name_method)
          end

          # Copy the #{name} header file to result source dir
          # @param [String] root_dir the directory of generation results
          define_method(:"cp_#{name}_file_path") do |root_dir|
            FileUtils.cp(
              send(:"src_#{name}_file_path"), send(:"dst_#{name}_file_path", root_dir))
          end
        end

        %w(major surface).each do |name|
          # Finds index of atom properties that correspond to #{name} atom instance of
          # crystal lattice
          #
          # @return [Integer] see at #crystal_atom_index result
          define_method(:"#{name}_atom_index") do
            ap = find_crystal_atom(instance.send(:"#{name}_crystal_atom"))
            @classifier.index(ap)
          end

          # Finds index of atom properties that correspond to #{name} atom instance of
          # crystal lattice
          #
          # @return [Integer] see at #crystal_atom_index result
          define_method(:"#{name}_atom_actives") do
            ap = find_crystal_atom(instance.send(:"#{name}_crystal_atom"))
            ap.unbonded_actives_num
          end
        end

        # Finds the crystal atom by atom information hash
        # @param [Hash] info about crystal atom
        # @return [Organizers::AtomProperties] the atom properties that correspond to
        #   target atom info
        def find_crystal_atom(info)
          full_info = info.dup
          full_info[:lattice] = @lattice
          target = @classifier.props.find { |prop| prop.correspond?(full_info) }
          target || raise('Used crystal atom was not found!')
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
