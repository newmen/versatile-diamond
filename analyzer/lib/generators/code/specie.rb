module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Specie class
      class Specie < CppClassWithGen
        include PolynameClass
        include PartialRenderer

        # Initialize specie code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Organizers::DependentSpec] spec source file for which will be
        #   generated
        def initialize(generator, spec)
          super(generator)
          @spec = spec
          @_class_name, @_enum_name, @_used_iterators = nil

          @_atoms_delta, @_atoms_sequence, @_symmetric_atoms = nil
          @symmetrics = collect_symmetrics
        end

        # таки создать якоря для структуры

        # @override
        def generate(root_dir)
          if symmetric?
            # - три шаблона: original_specie, symmetric_specie, find algorithms
            # - создавая симметрию проверять нужна ли она, по потомкам
            # - original_specie полностью делигирует на текущий specie, кроме метода
            #   render_find_algorithms?
          else
            # один шаблон для specie with find algorithms
          end

          # если в родительской структуре используются симметричные атомы, то в
          # алгоритмы поиска подставлять итерацию каждой симметрии
        end

        # Counts delta between atoms num of current specie and sum of atoms num of
        # all parents
        #
        # @return [Integer] the delta between atoms nums
        def atoms_delta
          @_atoms_delta ||= links.size - parents.map(&:links).map(&:size).reduce(:+)
        end

        # Detects additional atoms which are not presented in parent species
        # @return [Array] the array of additional atoms
        def addition_atoms
          original_links = @spec.links
          all_atoms = original_links.keys
          atoms = parents.reduce(all_atoms) do |acc, parent|
            acc - parent.atoms_sequence
          end
          atoms.sort_by { |a| original_links[a].size }
        end

        # Makes general sequence of atoms which will be used for get an atom index
        # @return [Array] the general sequence of atoms of current specie
        def atoms_sequence
          @_atoms_sequence ||=
            if parents_num == 0
              @spec.links.to_a.sort_by { |_, l| l.size }.map(&:first)
            else
              result = atoms_delta > 0 ? addition_atoms : []
              parents.reduce(result) { |acc, parent| acc + parent.atoms_sequence }
            end
        end

        # Gets an index of some atom
        # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which index will be got from general sequence
        # @return [Integer] the index of atom in general sequence
        def atom_index(atom)
          atoms_sequence.index(atom)
        end

        # Finds all symmetric intersecs
        # @return [Array] the array of hashes where each hash contain pointing to
        #   symmetrical atoms
        def collect_symmetrics
          intersec =
            SpeciesComparator.intersec(target, target, collaps_multi_bond: false)
          differents = intersec.reject { |isec| isec.all? { |a, b| a == b } }
          differents.map { |isec| Hash[isec.to_a] }
        end

        def anchors
          links.keys
        end

        # Finds all atoms which have symmetric analogy
        # @return [Set] the set of atoms
        def symmetric_atoms
          return @_symmetric_atoms if @_symmetric_atoms
          pairs = @symmetrics.reduce([]) do |acc, intersec|
            acc + intersec.reject(&:==)
          end
          @_symmetric_atoms = Set[pairs]
        end

        # Is symmetric specie? If children species uses same as own atom and it atom
        # has symmetric analogy
        #
        # @return [Boolean] is symmetric specie or not
        def symmetric?
          children.any? do |child|
            child.anchors.any? { |atom| symmetric_atoms.include?(atom) }
          end
        end

        [
          ['class', :classify, ''],
          ['enum', :upcase, '_']
        ].each do |name, method, separator|
          method_name = :"#{name}_name"
          var_name = :"@_#{method_name}"

          # Makes #{name} name for current specie
          # @return [String] the result #{name} name
          define_method(method_name) do
            var = instance_variable_get(var_name)
            return var if var

            m = @spec.name.to_s.match(/(\w+)(\(.+?\))?/)
            addition = "#{separator}#{name_suffix(m[2])}" if m[2]
            instance_variable_set(var_name, "#{m[1].send(method)}#{addition}")
          end
        end

        # Gets the result file name
        # @return [String] the result file name of atom class
        # @override
        def file_name
          enum_name.downcase
        end

        # Gets number of sceleton atoms used in specie and different from atoms of
        # parent specie
        #
        # @return [Integer] the number of atoms
        # TODO: must be private
        def atoms_num
          links.size
        end

      private

        # Gets target of current generation
        # @return [Organizers::DependentSpec || Organizers::SpecResidual] the
        #   minimal rest of current target specie
        def target
          @spec.rest || @spec
        end

        # Gets target links between different atoms
        # @return [Hash] the links between atoms
        def links
          target.links
        end

        # Checks that internal @spec variable is DependentBaseSpec
        # @return [Boolean] internal variable is dependent base spec or not
        def dependent_base?
          @spec.is_a?(Organizers::DependentBaseSpec)
        end

        # Gets the parent specie classes
        # @return [Array] the array of parent specie class generators
        def parents
          prs = @spec.is_a?(Organizers::DependentBaseSpec) ?
            @spec.parents : (@spec.parent ? [@spec.parent] : [])
          prs.map { |parent| @generator.specie_class(parent) }
        end

        # Gets the children specie classes
        # @return [Array] the array of children specie class generators
        def children
          @spec.children.map { |child| @generator.specie_class(child) }
        end

        # Checks that specie have children
        # @return [Boolean] is parent or not
        def parent?
          !@spec.children.empty?
        end

        # Checks that specie have reactions
        # @return [Boolean] is specific or not
        def specific?
          !@spec.reactions.empty?
        end

        # Checks that specie have there objects
        # @return [Boolean] is lateral or not
        def lateral?
          !@spec.theres.empty?
        end

        # Makes base classes string for current specie class instance
        # @return [String] combined base classes of engine framework
        def base_classes_str
          "public #{wrapped_base_class}#{iterator_classes_str}"
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
          delta = atoms_delta
          delta > 0 ? "AdditionalAtomsWrapper<#{base_class}, #{delta}>" : base_class
        end

        # Wraps combined base engine class by classes which works with handbook
        # @return [String] full major base class
        def wrapped_base_class
          base = "Base<#{wrapped_engine_class_name}, #{enum_name}, #{atoms_num}>"
          base = "Specific<#{base}>" if specific?
          base = "Sidepiece<#{base}>" if lateral?
          base
        end

        # Gets outer template name of base class
        # @return [String] the outer base class name
        def outer_base_class
          lateral? ? 'Sidepiece' : (specific? ? 'Specific' : 'Base')
        end

        # Gets outer template name of base class
        # @return [String] the outer base class name
        def outer_base_file
          outer_base_class.underscore
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

          lattices = links.reduce(Set.new) do |acc, (atom, list)|
            list.empty? ? acc : (acc << atom.lattice)
          end

          @_used_iterators = lattices.to_a.compact.map do |lattice|
            generator.lattice_class(lattice).iterator
          end
        end

        # Combines used iterators for using them as parent classes
        # @return [String] the string that correspond to parent classes from which
        #   specie class instance will be inheritance in source code
        def iterator_classes_str
          class_names = used_iterators.map { |iter| "public #{iter.class_name}" }
          class_names.empty? ? '' : ", #{class_names.join(', ')}"
        end

        # Gets list of used iterator files
        # @return [Array] the array of file names
        def iterator_files
          used_iterators.map(&:file_name)
        end

        # Makes arguments string for static find method
        # @return [String] the arguments string of find method
        def find_arguments_str
          parents.size == 1 ? "#{parents.first.class_name} *target" : 'Atom *anchor'
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
        def name_suffix(brackets_str)
          params_str = brackets_str.scan(/\((.+?)\)/).first.first
          params = params_str.scan(/(\w+): (.)/)
          groups = params.group_by(&:first)
          strs = groups.map do |k, gs|
            states = gs.map { |item| item.last == '*' ? 's' : item.last }.join
            "#{k.upcase}#{states}"
          end
          strs.join
        end
      end

    end
  end
end
