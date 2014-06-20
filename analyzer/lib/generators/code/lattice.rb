module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Lattice class
      class Lattice < CppClass
        include PolynameClass
        extend SourceFileCopier
        extend Forwardable

        def_delegators :instance, :default_surface_height
        copy_source :crystal_properties, :relations

        # Initializes by concept lattice
        # @param [Concepts::Lattice] lattice the target concept
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
