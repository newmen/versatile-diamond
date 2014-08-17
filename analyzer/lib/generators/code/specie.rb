module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Specie class
      class Specie < BaseSpecie
        include EnumerableFileName

        attr_reader :spec, :original

        # Initialize specie code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Organizers::DependentSpec] spec source file for which will be
        #   generated
        def initialize(generator, spec)
          super(generator)

          @spec = spec
          if spec.simple?
            # for this species should not be called methods that dependent from these
            # instance variables
            # TODO: separate for AbstractSpecie which will contain methods for getting
            # class name of simple species, because class name using in env.yml config
            # file
            @original, @symmetrics = nil
          else
            @original = OriginalSpecie.new(@generator, self)

            @sequence = @generator.sequences_cacher.get(spec)
            @symmetrics = @sequence.symmetrics(@generator, @original)
          end

          @_class_name, @_enum_name, @_used_iterators = nil
        end

        # Generates source code for specie
        # @param [String] root_dir see at #super same argument
        # @override
        def generate(root_dir)
          if symmetric?
            @original.generate(root_dir)
            @symmetrics.each { |symmetric| symmetric.generate(root_dir) }
          else
            super
          end
        end

        # Is symmetric specie? If children species uses same as own atom and it atom
        # has symmetric analogy
        #
        # @return [Boolean] is symmetric specie or not
        def symmetric?
          !@symmetrics.empty?
        end

        PREF_METD_SEPS.each do |name, method, separator|
          method_name = :"#{name}_name"
          var_name = :"@_#{method_name}"

          # Makes #{name} name for current specie
          # @return [String] the result #{name} name
          define_method(method_name) do
            var = instance_variable_get(var_name)
            return var if var

            m = spec.name.to_s.match(/(\w+)(\(.+?\))?/)
            addition = "#{separator}#{name_suffixes(m[2]).join(separator)}" if m[2]
            instance_variable_set(var_name, "#{m[1].send(method)}#{addition}")
          end
        end

        # Gets number of sceleton atoms used in specie and different from atoms of
        # parent specie
        #
        # @return [Integer] the number of atoms
        # TODO: must be private
        def atoms_num
          spec.target.links.size
        end

        # Wraps combined base engine class by classes which works with handbook
        # @return [String] full major base class
        def wrapped_base_class_name
          base = "Base<#{wrapped_engine_class_name}, #{enum_name}, #{atoms_num}>"
          base = "Specific<#{base}>" if specific?
          base = "Sidepiece<#{base}>" if lateral?
          base
        end

        # Provides classes list from which occur inheritance when template renders
        # @return [Array] the array of cpp class names
        # TODO: must be private
        def base_classes
          [base_class] + iterator_classes
        end

        # Gets outer template name of base class
        # @return [String] the outer base class name
        def outer_base_file
          outer_base_class.underscore
        end

        # Checks that current specie is find algorithm root
        # @return [Boolean] is find algorithm root or not
        def find_root?
          parents.size != 1
        end

        # Gets a list of parents species full header file path of which will be
        # included in header file of current specie if it isn't find algorithm root
        #
        # @return [Array] the array of parent specie code generators
        def header_parents_dependencies
          find_root? ? [] : parents
        end

        # The printable name which will be shown when debug calculation output
        # @return [String] the name of specie which used by user in DSL config file
        def print_name
          @spec.name.to_s
        end

      private

        # Specie class has find algorithms by default
        # @return [Boolean] true
        def render_find_algorithms?
          true
        end

        # Gets the parent specie classes
        # @return [Array] the array of parent specie class generators
        def parents
          spec.parents.map(&method(:specie_class))
        end

        # Gets the children specie classes
        # @return [Array] the array of children specie class generators
        def children
          spec.non_term_children.map(&method(:specie_class))
        end

        # Checks that specie have children
        # @return [Boolean] is parent or not
        def parent?
          !spec.children.empty?
        end

        # Checks that specie have reactions
        # @return [Boolean] is specific or not
        def specific?
          !spec.reactions.empty?
        end

        # Checks that specie have there objects
        # @return [Boolean] is lateral or not
        def lateral?
          !spec.theres.empty?
        end

        # Combines public inheritance string
        # @param [Array] classes the array of string names of cpp classes
        # @return [String] the string which could be used for inheritance
        def public_inheritance(classes)
          classes.map { |klass| "public #{klass}" }.join(', ')
        end

        # Makes base classes for current specie class instance
        # @return [String] combined base classes of engine framework
        def base_class
          symmetric? ? generalized_class_name : wrapped_base_class_name
        end

        # Combines base engine templated specie classes
        # @return [String] unwrapped combined base engine template classes
        def base_engine_class_name
          base_class = parent? ? 'ParentSpec' : 'BaseSpec'
          parents_num = parents.size
          parents_num == 0 ?
            "SourceSpec<#{base_class}, #{atoms_num}>" :
            "DependentSpec<#{base_class}, #{parents_num}>"
        end

        # Checks that specie contain additional atoms and if truth then wraps base
        # class name
        #
        # @return [String] the wrapped or not base engine class name
        def wrapped_engine_class_name
          base_class = base_engine_class_name
          delta = @sequence.delta
          delta > 0 ? "AdditionalAtomsWrapper<#{base_class}, #{delta}>" : base_class
        end

        # Gets outer template name of base class
        # @return [String] the outer base class name
        def outer_base_class
          lateral? ? 'Sidepiece' : (specific? ? 'Specific' : 'Base')
        end

        # Makes string by which base constructor will be called
        # @return [String] the string with calling base constructor
        def outer_base_call
          params = constructor_arguments.map(&:last).join(', ')
          "#{outer_base_class}(#{params})"
        end

        # Gets the collection of used crystal atom iterator classes
        # @return [Array] used crystal atom iterators
        def used_iterators
          return @_used_iterators if @_used_iterators

          rest_links = spec.target.links
          anchors = rest_links.keys
          lattices = rest_links.reduce(Set.new) do |acc, (atom, list)|
            next acc if list.empty? || !atom.lattice

            crystal_nbr_exist = list.map(&:first).any? do |a|
              a.lattice && anchors.include?(a)
            end

            crystal_nbr_exist ? (acc << atom.lattice) : acc
          end

          @_used_iterators = lattices.to_a.compact.map do |lattice|
            @generator.lattice_class(lattice).iterator
          end
        end

        # Combines used iterators for using them as parent classes
        # @return [Array] the array that contain parent class names from which
        #   specie class instance will be inheritance in source code
        def iterator_classes
          used_iterators.map(&:class_name)
        end

        # Gets a list of used iterator files
        # @return [Array] the array of file names
        def iterator_files
          used_iterators.map(&:file_name)
        end

        # Gets a list of species full header file path of which will be included in
        # header file of current specie
        #
        # @return [Array] the array of species which should be included in header file
        def header_species_dependencies
          if symmetric?
            [@original] + @symmetrics
          else
            header_parents_dependencies
          end
        end

        # Gets a list of species full header file path of which will be included in
        # source file of current specie
        #
        # @return [Array] the array of species which should be included in source file
        def source_species_dependencies
          parents + children
        end

        # Gets classes from which current code instance will be inherited if specie is
        # symmetric
        #
        # @return [Array] the array of class names where one of which used original
        #   and symmetric instances
        def generalized_class_name
          original_class = @original.class_name
          symmetric_classes = @symmetrics.map(&:class_name).join(', ')
          "Symmetric<#{original_class}, #{symmetric_classes}>"
        end

        # Makes arguments string for static find method
        # @return [String] the arguments string of find method
        def find_arguments_str
          find_root? ? 'Atom *anchor' : "#{parents.first.class_name} *target"
        end

        # Makes arguments string for constructor method
        # @return [Array] the arguments string of constructor method
        def constructor_arguments_str
          constructor_arguments.map(&:join).join(', ')
        end

        # Makes arguments for constructor method
        # @return [Array] the arguments of constructor method
        def constructor_arguments
          [major_constructor_argument]
        end

        # Selects major constructor argument by number of specie parents
        # @return [Array] the first item is type and the second is variable name
        def major_constructor_argument
          parents_num = parents.size
          if parents_num == 0
            ['Atom **', 'atoms']
          elsif parents_num == 1
            ['ParentSpec *', 'parent']
          else # parents_num > 1
            ['ParentSpec **', 'parents']
          end
        end

        # Makes suffix of name which is used in name builder methods
        # @param [String] brackets_str the string which contain brackets and some
        #   additional params of specie in them
        # @return [String] the suffix of name
        # @example generating name
        #   '(ct: *, ct: i, cr: i)' => 'CTsiCRi'
        def name_suffixes(brackets_str)
          params_str = brackets_str.scan(/\((.+?)\)/).first.first
          params = params_str.scan(/(\w+): (.)/)
          strs = params.group_by(&:first).map do |k, gs|
            states = gs.map { |item| item.last == '*' ? 's' : item.last }.join
            "#{k.upcase}#{states}"
          end
          strs.sort
        end

        # Gets sorted anchors to atom sequence
        # @return [Array] the array of anchor atoms
        def anchors
          @sequence.short
        end

        # Delegates classification to atom classifier from engine code generator
        # @param [Concepts::Atom | Concepts::AtomRefernce | Concepts::SpecificAtom]
        #   atom which will be classificated
        # @return [Integer] an index of classificated atom
        def role(atom)
          @generator.classifier.index(@spec, atom)
        end

        # Gets a sequence of indexes of anchor atoms
        # @return [String] the sequence of indexes joined by comma
        def indexes_sequence
          anchors.map { |a| @sequence.atom_index(a) }.join(', ')
        end

        # Gets a list of anchor atoms roles where each role is atom properties index
        # in atom classification
        #
        # @return [Array] the list of anchors roles
        def roles_sequence
          anchors.map(&method(:role)).join(', ')
        end

        # Gets the specie class code generator
        # @param [Organizers::DependentSpec] dept_spec dependent specie the code
        #   generator of which will be got
        # @return [Specie]
        def specie_class(dept_spec)
          @generator.specie_class(dept_spec.name)
        end

        # The additional path for current instance
        # @return [String] the additional directories path
        # @override
        def additional_path
          'species'
        end
      end

    end
  end
end
