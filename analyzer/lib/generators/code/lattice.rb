module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Lattice class
      class Lattice < CppClassWithGen
        extend Forwardable
        include SourceFileCopier
        include PolynameClass

        def_delegators :instance, :default_surface_height

        class << self
          def additional_sources(*names)
            names.each do |name|
              name_method = :"#{name}_name"
              file_name_method = :"#{name}_file_name"

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

              # The name of lattice #{name} code instance
              # @return [String] the #{name} underscored instance name
              define_method(name_method) do
                "#{class_name.underscore}_#{name}"
              end
              private name_method
            end
          end
        end

        additional_sources :crystal_properties, :relations

        # Initializes by concept lattice
        # @param [Concepts::Lattice] lattice the target concept
        # @param [EngineCode] generator see at #super same argument
        def initialize(generator, lattice)
          super(generator)
          @lattice = lattice
        end

        # Also copies relations cpp template class which own for each lattice
        # @param [String] root_dir see at #super same argument
        def generate(root_dir)
          super
          copy_file(root_dir, crystal_properties_file_name)
          copy_file(root_dir, relations_file_name)
          iterator.generate(root_dir)
        end

        # Get the cpp class name
        # @return [String] the class name of atom
        def class_name
          instance.class.to_s
        end

        # Gets iterator for current lattice
        # @return [LatticeAtomsIterator] the iterator between atoms of current lattice
        def iterator
          LatticeAtomsIterator.new(self)
        end

      private

        def_delegator :generator, :classifier
        def_delegator :@lattice, :instance

        %w(major surface).each do |name|
          # Finds index of atom properties that correspond to #{name} atom instance of
          # crystal lattice
          #
          # @return [Integer] see at #crystal_atom_index result
          define_method(:"#{name}_atom_index") do
            ap = find_crystal_atom(instance.public_send(:"#{name}_crystal_atom"))
            classifier.index(ap)
          end

          # Finds index of atom properties that correspond to #{name} atom instance of
          # crystal lattice
          #
          # @return [Integer] see at #crystal_atom_index result
          define_method(:"#{name}_atom_actives") do
            ap = find_crystal_atom(instance.public_send(:"#{name}_crystal_atom"))
            ap.unbonded_actives_num
          end
        end
        public :major_atom_index

        # Finds the crystal atom by atom information hash
        # @param [Hash] info about crystal atom
        # @return [Organizers::AtomProperties] the atom properties that correspond to
        #   target atom info
        def find_crystal_atom(info)
          full_info = info.dup
          full_info[:lattice] = @lattice
          target = classifier.props.find { |prop| prop.correspond?(full_info) }
          target || raise('Used crystal atom was not found!')
        end

        # Gets the name of method which will build each atom under crystal creation
        # @return [String] the builder method name
        def builder_method_name
          AtomBuilder.method_name(instance.major_crystal_atom[:atom_name], @lattice)
        end

        # Gets the list of objects which headers should be included in body file
        # @return [Array] the list of including objects
        # @override
        def body_include_objects
          [generator.atom_builder, generator.finder]
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
