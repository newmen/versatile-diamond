module VersatileDiamond
  module Organizers

    # Classifies atoms in specs and associate each atom type with some value,
    # which will be used for detecting overlapping specs between each other
    # and generates optimal specs search algorithm (after some reaction has
    # been realised) for updating of real specs set
    class AtomClassifier

      # Initialize a classifier by empty sets of properties
      def initialize
        @all_props = {}
        @unrelevanted_props = Set.new
        @used_relevants_num = 0
        @index_counter = -1
      end

      # Provides the hash of all analyzed atom properties
      # @return [Hash] the hash with set of atom properties
      def props_hash
        if @used_relevants_num == 0
          Hash[@unrelevanted_props.to_a.map.with_index { |prop, i| [i, prop] }]
        else
          @all_props
        end
      end

      # Provides the array of all analyzed atom properties
      # @return [Array] the array of all presented properties
      def props
        props_hash.values
      end

      # Analyze spec and store all uniq properties
      # @param [DependentBaseSpec | DependentSpecificSpec] spec the analyzing spec
      def analyze(spec)
        props = spec.links.map { |atom, _| AtomProperties.new(spec, atom) }
        props.each do |prop|
          @used_relevants_num += 1 if prop.relevant?
          next if internal_index(prop)

          store_prop(prop, check: false)

          activated_prop = prop
          while (activated_prop = activated_prop.activated)
            store_prop(activated_prop)
          end

          deactivated_prop = prop
          while (deactivated_prop = deactivated_prop.deactivated)
            store_prop(deactivated_prop)
          end
        end
      end

      # Organizes dependencies between properties
      def organize_properties!
        add_default_lattices_atoms

        ordered_props_list = props.sort
        organize_by_inclusion!(ordered_props_list)
        organize_by_relatives!(ordered_props_list)
      end

      # Classify spec and return the hash where keys are order numbers of properties
      # and values are numbers of atoms in spec with same properties
      #
      # @param [DependentSpec | SpecResidual] spec the analyzing spec
      # @option [DependentWrappedSpec] :without do not classify atoms like as from
      #   passed spec (not using when spec is termination spec)
      # @return [Hash] result of classification
      def classify(spec)
        if spec.is_a?(DependentTermination)
          current_props = props.select { |prop| spec.terminations_num(prop) > 0 }

          current_props.each_with_object({}) do |prop, hash|
            index = index(prop)
            image = prop.to_s
            hash[index] = [image, spec.terminations_num(prop)]
          end
        else
          target = spec.target
          atoms = target.links.keys

          atoms.each_with_object({}) do |atom, hash|
            prop = AtomProperties.new(target, atom)
            index = index(prop)
            image = prop.to_s
            hash[index] ||= [image, 0]
            hash[index][1] += 1
          end
        end
      end

      # Finds index of passed property
      # @param [Array] args which will passed to #index_in method
      # @return [Integer] the index of properties or nil
      def index(*args)
        index_in(props_hash, *args)
      end

      # Gets number of all different properties
      # @return [Integer] quantity of all uniq properties
      def all_types_num
        @all_props.size
      end

      # Gets number of non relevants different properties
      # @return [Integer] quantity of uniq properties without relevants
      def notrelevant_types_num
        @unrelevanted_props.size
      end

      # Checks that properties by index has relevants
      # @param [Integer] index the index of properties
      # @return [Boolean] has or not
      def has_relevants?(index)
        !!props_hash[index].relevant?
      end

      # Gets matrix of transitive closure for atom properties dependencies
      # @return [TransitiveMatrix] the general transitive closure matrix
      def general_transitive_matrix
        @_tmatrix ||= TransitiveMatrix.new(self, :smallests, :sames)
      end

      # Gets array where each element is index of result specifieng of atom
      # properties
      #
      # @return [Array] the specification array
      def specification
        props.map do |prop|
          index(smallests_transitive_matrix.specification_for(detect_prop(prop)))
        end
      end

      # Gets transitions array of actives atoms to notactives
      # @return [Array] the transitions array
      def actives_to_deactives
        collect_transitions(:deactivated)
      end

      # Gets transitions array of notactives atoms to actives
      # @return [Array] the transitions array
      def deactives_to_actives
        collect_transitions(:activated)
      end

      # Gets all used lattices in analysed results
      # @return [Array] the array of lattice instances
      def used_lattices
        props.map(&:lattice).uniq
      end

      # Checks that the first atom properties are the second atom properties
      # @param [AtomProperties] bigger
      # @param [AtomProperties] smallest
      # @return [Boolean] is or not
      def is?(bigger, smallest)
        general_transitive_matrix[detect_prop(bigger), detect_prop(smallest)]
      end

      # Selects the children of passed atom properties
      # @param [AtomProperties] smallest for which the children properties will be
      #   gotten
      # @return [Array] the list of children atom properties
      def children_of(smallest)
        props.select do |prop|
          prop != smallest && is?(prop, smallest) && most_bigger?(prop)
        end
      end

    private

      # Checks that passed atom properties haven't most bigger
      # @param [AtomProperties] bigger atom properties which will be checked
      # @return [Boolean] is most bigger or not
      def most_bigger?(bigger)
        !props.any? { |prop| prop != bigger && is?(prop, bigger) }
      end

      # Finds index of passed property in collection
      # @overloaded index(collection, prop)
      #   @param [Array] collection where index will be found
      #   @param [AtomProperties] prop the property index of which will be found
      # @overloaded index(collection, spec, atom)
      #   @param [Array] collection where index will be found
      #   @param [DependentSpec | SpecResidual] spec the spec for which properties of
      #     atom will be found
      #   @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #     atom for which properties will be found
      # @return [Integer] the index of properties or nil
      def index_in(collection, *args)
        prop =
          if args.size == 1
            args.first
          elsif args.size == 2
            AtomProperties.new(*args)
          else
            raise ArgumentError
          end
        collection.key(prop)
      end

      # Finds internal index of passed property
      # @param [Array] args which will passed to #index_in method
      # @return [Integer] the index of properties or nil
      def internal_index(*args)
        index_in(@all_props, *args)
      end

      # Adds default atoms of all used lattices
      def add_default_lattices_atoms
        used_lattices.compact.each do |lattice|
          %w(major surface).each do |name|
            atom_hash = lattice.instance.send(:"#{name}_crystal_atom")
            props_hash = atom_hash.merge(lattice: lattice)
            store_prop(AtomProperties.new(props_hash))
          end
        end
      end

      # Organizes dependencies between atom properties by checking inclusion
      # @param [Array] props_list the observing atom properties
      def organize_by_inclusion!(props_list)
        iterate_props_list(props_list) do |first, internal|
          next unless internal.contained_in?(first)
          first.add_smallest(internal)
        end
      end

      # Organizes dependencies between atom properties by checking relative states
      # @param [Array] props_list the observing atom properties
      def organize_by_relatives!(props_list)
        iterate_props_list(props_list) do |first, internal|
          if first.same_incoherent?(internal)
            if first.same_hydrogens?(internal)
              first.add_smallest(internal)
            else
              first.add_same(internal)
            end
          elsif first.same_unfixed?(internal)
            first.add_same(internal)
          end
        end
      end

      # Iterates passed list of atom properties
      # @param [Array] props_list the iterating atom properties
      # @yield [AtomProperties, AtomProperties] do with bigger and smallest atom
      #   properties
      def iterate_props_list(props_list, &block)
        props_list_dup = props_list.dup
        until props_list_dup.empty?
          first = props_list_dup.shift
          props_list_dup.each { |internal| block[internal, first] }
        end
      end

      # Gets a new index of adding properties
      # @return [Integer] index of new properties
      def new_index
        @index_counter += 1
      end

      # Stores passed prop and it unrelevanted analog
      # @param [AtomProperties] prop the storing properties
      # @option [Boolean] :check before storing checks or not index of
      #   properties
      def store_prop(prop, check: true)
        @all_props[new_index] = prop unless check && internal_index(prop)

        unless prop.incoherent?
          incoherent_prop = prop.incoherent
          store_prop(incoherent_prop) if incoherent_prop
        end

        unrel_prop = prop.unrelevanted
        @all_props[new_index] = unrel_prop unless internal_index(unrel_prop)
        @unrelevanted_props << detect_prop(unrel_prop)
      end

      # Detects analogies atom properties
      # @param [AtomProperties] prop the  atom properties search patern
      # @return [AtomProperties] analogies atom properties from internal value
      def detect_prop(prop)
        @all_props[internal_index(prop)]
      end

      # Collects transitions array by passed method name
      # @param [Symbol] method_name which will be called
      # @return [Array] collected array
      def collect_transitions(method_name)
        props_hash.map do |p, prop|
          other = prop.public_send(method_name)
          other && (i = index(other)) && p != i ? i : p
        end
      end

      # Gets matrix of transitive closure for smallests atom properties
      # dependencies
      #
      # @return [TransitiveMatrix] the transitive closure matrix of smallests
      #   dependencies
      def smallests_transitive_matrix
        @_st_matrix ||= TransitiveMatrix.new(self, :smallests)
      end
    end

  end
end
