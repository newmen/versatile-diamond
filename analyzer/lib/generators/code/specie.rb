module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Specie class
      class Specie < BaseSpecie
        include SpecieInside
        extend Forwardable

        def_delegators :@detector, :symmetric_atom?, :symmetric_atoms
        attr_reader :spec, :original, :sequence, :essence

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
            @original, @symmetrics, @sequence, @detector, @essence = nil
          else
            @original = OriginalSpecie.new(generator, self)
            @sequence = generator.sequences_cacher.get(spec)
            @essence = Essence.new(self)
          end

          @_class_name, @_enum_name, @_file_name, @_used_iterators = nil
        end

        # Runs find symmetries algorithm by detector
        # Should be called after specie created
        def find_symmetries!
          unless spec.simple?
            @detector = generator.detectors_cacher.get(spec)
            @symmetrics = @detector.symmetry_classes
          end
        end

        # Generates source code for specie
        # @param [String] root_dir see at #super same argument
        # @override
        def generate(root_dir)
          if symmetric?
            @original.generate(root_dir)
            @symmetrics.each { |symmetric| symmetric.generate(root_dir) }
          end
          super
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
            addition = addition.public_send(method) if addition && name == 'file'
            head = eval("m[1].#{method}")
            instance_variable_set(var_name, "#{head}#{addition}")
          end
        end

        # Wraps combined base engine class by classes which works with handbook
        # @return [String] full major base class
        def wrapped_base_class_name
          base = "Base<#{wrapped_engine_class_name}, #{enum_name}, #{atoms_num}>"
          base = "Specific<#{base}>" if specific?
          base = "Sidepiece<#{base}>" if sidepiece?
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
          spec.source? || spec.complex?
        end

        # Gets a list of parents species full header file path of which will be
        # included in header file of current specie if it isn't find algorithm root
        #
        # @return [Array] the array of parent specie code generators
        def header_parents_dependencies
          find_root? ? [] : parents
        end

        # Gets children species without species which are find algorithm roots
        # @return [Array] the array of children specie code generators without find
        #   algorithm roots
        def non_root_children
          children.reject(&:find_root?)
        end

        # The printable name which will be shown when debug calculation output
        # @return [String] the name of specie which used by user in DSL config file
        def print_name
          spec.name.to_s
        end

        def inspect
          class_name
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
          spec.parents.map { |parent| specie_class(parent.original) }
        end

        # Gets the children specie classes
        # @return [Array] the array of children specie class generators
        def children
          spec.non_term_children.map(&method(:specie_class))
        end

        # Checks that specie have children
        # @return [Boolean] is parent or not
        def parent?
          !children.empty?
        end

        # Gets list of local reactions for current specie
        # @return [Array] the list of local reactions
        def local_reactions
          if generator.handbook.ubiquitous_reactions_exists?
            spec.reactions.select(&:local?)
          else
            []
          end
        end

        # Gets list of typical reactions for current specie
        # @return [Array] the list of typical reactions
        def typical_reactions
          spec.reactions - local_reactions - lateral_reactions
        end

        # Gets list of lateral reactions for current specie
        # @return [Array] the list of lateral reactions
        def lateral_reactions
          spec.reactions.select(&:lateral?)
        end

        # Checks that ubiquitous reactions prestented and specie have local reactions
        # @return [Boolean] is local or not
        def local?
          !local_reactions.empty?
        end

        # Checks that specie have typical reactions
        # @return [Boolean] is specific or not
        def specific?
          !typical_reactions.empty?
        end

        # Checks that specie have there objects
        # @return [Boolean] is lateral specie or not
        def sidepiece?
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
          parents_num = spec.parents.size
          parents_num == 0 ?
            "SourceSpec<#{base_class}, #{atoms_num}>" :
            "DependentSpec<#{base_class}, #{parents_num}>"
        end

        # Checks that specie contain additional atoms and if truth then wraps base
        # class name
        #
        # @return [String] the wrapped or not base engine class name
        def wrapped_engine_class_name
          base = base_engine_class_name
          base = "AdditionalAtomsWrapper<#{base}, #{delta}>" if delta > 0

          if local?
            local_reactions.reduce(base) do |acc, reaction|
              _, a = reaction.complex_source_spec_and_atom
              "LocalableRole<#{acc}, #{index(a)}>"
            end
          else
            base
          end
        end

        # Gets outer template name of base class
        # @return [String] the outer base class name
        def outer_base_class
          sidepiece? ? 'Sidepiece' : (specific? ? 'Specific' : 'Base')
        end

        # Makes string by which base constructor will be called
        # @return [String] the string with calling base constructor
        def outer_base_call
          "#{outer_base_class}(#{constructor_variables_str})"
        end

        # Gets the collection of used crystal atom iterator classes
        # @return [Array] used crystal atom iterators
        def used_iterators
          return @_used_iterators if @_used_iterators

          lattices =
            @essence.cut_links.each_with_object(Set.new) do |(atom, rels), acc|
              if !rels.empty? && atom.lattice && rels.map(&:first).any?(&:lattice)
                acc << atom.lattice
              end
            end

          @_used_iterators = lattices.to_a.compact.map do |lattice|
            generator.lattice_class(lattice).iterator
          end
        end

        # Combines used iterators for using them as parent classes
        # @return [Array] the array that contain parent class names from which
        #   specie class instance will be inheritance in source code
        def iterator_classes
          used_iterators.map(&:class_name)
        end

        # Gets a list of species full header file path of which will be included in
        # header file of current specie
        #
        # @return [Array] the array of species which should be included in header file
        def head_include_objects
          species =
            if symmetric?
              [@original] + @symmetrics
            else
              header_parents_dependencies
            end

          used_iterators + species + [common_base_class_file]
        end

        # Gets a list of species full header file path of which will be included in
        # source file of current specie
        #
        # @return [Array] the array of species which should be included in source file
        def body_include_objects
          ((symmetric? || find_root?) ? parents.uniq : []) + non_root_children
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
          find_root? ? 'Atom *anchor' : "#{parents.first.class_name} *parent"
        end

        # Makes string with constructor signature variables
        # @return [String] the string with constructor variables sequence
        def constructor_variables_str
          constructor_arguments.map(&:last).join(', ')
        end

        # Makes arguments string for constructor method
        # @return [String] the arguments string of constructor method
        def constructor_arguments_str
          constructor_arguments.map(&:join).join(', ')
        end

        # Makes arguments for constructor method
        # @return [Array] the arguments of constructor method
        def constructor_arguments
          additional_arguments = additional_constructor_argument
          arguments = []
          arguments << additional_arguments unless additional_arguments.empty?
          arguments << major_constructor_argument
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

        # Checks that if specie has addition atoms then them should be plased to
        # constructor signature
        #
        # @return [Array] if addition atoms is not presented then empty array returned,
        #   and the first item is type and the second is variable name overwise
        def additional_constructor_argument
          if delta == 0
            []
          elsif delta == 1
            ['Atom *', 'additionalAtom']
          else # delta > 1
            ['Atom **', 'additionalAtoms']
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

        # Gets sorted anchors from atoms sequence
        # @return [Array] the array of anchor atoms
        def ordered_anchors
          sequence.short
        end

        # Gets a sequence of indexes of anchor atoms
        # @return [String] the sequence of indexes joined by comma
        def indexes_sequence
          ordered_anchors.map(&method(:index)).join(', ')
        end

        # Gets a list of anchor atoms roles where each role is atom properties index
        # in atom classification
        #
        # @return [Array] the list of anchors roles
        def roles_sequence
          ordered_anchors.map(&method(:role)).join(', ')
        end

        # Gets a cpp code by which specie will be found when simulation doing
        # @return [String] the multilined string with cpp code
        def find_algorithm
          FindAlgorithmBuilder.new(generator, self).build
        end
      end

    end
  end
end
