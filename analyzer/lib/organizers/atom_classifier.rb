module VersatileDiamond
  module Organizers

    # Classifies atoms in specs and associate each atom type with some value,
    # which will be used for detecting overlapping specs between each other
    # and generates optimal specs search algorithm (after some reaction has
    # been realised) for updating of real specs set
    class AtomClassifier

      # Initialize a classifier by empty sets of properties
      # @param [Boolean] is_ions_presented identify that there are reactions with ions
      def initialize(is_ions_presented = true)
        @is_ions_presented = is_ions_presented

        @described_props = Set.new
        @over_danglings_props = Set.new
        @over_relevants_props = Set.new
        @unrelevanted_props = Set.new

        @_default_latticed_atoms = nil
        @_props_with_indexes = nil
        reset_caches!
      end

      # Provides the hash of all analyzed atom properties
      # @return [Hash] the hash with set of atom properties
      def props_hash
        @_props_hash ||= Hash[props_with_indexes]
      end

      # Provides the array of all analyzed atom properties
      # @return [Array] the array of all presented properties
      def props
        @_props ||= all_props.to_a.sort
      end

      # Analyze spec and store all uniq properties
      # @param [DependentBaseSpec | DependentSpecificSpec] spec the analyzing spec
      # @option [Boolean] :with_ions is flag which identify that there are reactions
      #   with analyzing spec and ions of gase phase
      def analyze(spec, with_ions: true)
        raise 'Cache of properties already created' if @_props_with_indexes

        store_all_ioned = @is_ions_presented || with_ions
        avail_props = spec.links.map { |atom, _| AtomProperties.new(spec, atom) }
        avail_props.each do |prop|
          store_prop(@described_props, prop)
          if store_all_ioned
            store_all(:activated, prop)
            store_all(:deactivated, prop)
          end
        end
      end

      # Organizes dependencies between properties
      def organize_properties!
        add_default_latticed_atoms
        organize_by_inclusion!(props)
        organize_by_relatives!(props)
      end

      # Classify spec and return the hash where keys are order numbers of properties
      # and values are numbers of atoms in spec with same properties
      #
      # @param [DependentSpec | SpecResidual] spec the analyzing spec
      # @option [DependentWrappedSpec] :without do not classify atoms like as from
      #   passed spec (not using when spec is termination spec)
      # @return [Hash] result of classification
      def classify(spec)
        append_to = -> acc, prop, num do
          idx = index(prop)
          acc[idx] ||= [prop, 0]
          acc[idx][1] += num
        end

        if spec.is_a?(DependentTermination)
          current_props = props.select { |prop| spec.terminations_num(prop) > 0 }
          current_props.each_with_object({}) do |prop, acc|
            append_to[acc, prop, spec.terminations_num(prop)]
          end
        else
          spec.anchors.each_with_object({}) do |atom, acc|
            append_to[acc, AtomProperties.new(spec, atom), 1]
          end
        end
      end

      # Finds index of passed property in collection
      # @overloaded index(collection, prop)
      #   @param [AtomProperties] prop the property index of which will be found
      # @overloaded index(collection, spec, atom)
      #   @param [DependentSpec | SpecResidual] spec the spec for which properties of
      #     atom will be found
      #   @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #     atom for which properties will be found
      # @return [Integer] the index of properties or nil
      def index(*args)
        prop =
          if args.one?
            args.first
          elsif args.size == 2
            AtomProperties.new(*args)
          else
            raise ArgumentError
          end
        props_hash.key(prop)
      end

      # Gets number of all different properties
      # @return [Integer] quantity of all uniq properties
      def all_types_num
        all_props.size
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

      # Gets array where each element is index of much more specific atom properties
      # @return [Array] the specification array
      def specification
        props.map do |prop|
          index(smallests_transitive_matrix.specification_for(prop))
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

      # Gets the list of default atoms which are presented on lattice
      # @return [Array] the list of default latticed atoms
      def default_latticed_atoms
        @_default_latticed_atoms ||=
          used_lattices.compact.reduce([]) do |acc, lattice|
            acc + %w(major surface).map do |name|
              atom_hash = lattice.instance.send(:"#{name}_crystal_atom")
              props_hash = atom_hash.merge(lattice: lattice)
              AtomProperties.new(props_hash)
            end
          end
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
          prop != smallest && is?(prop, smallest) &&
            (prop.incoherent? || most_bigger?(prop))
        end
      end

    private

      # Checks that passed atom properties haven't most bigger
      # @param [AtomProperties] bigger atom properties which will be checked
      # @return [Boolean] is most bigger or not
      def most_bigger?(bigger)
        !props.any? { |prop| prop != bigger && is?(prop, bigger) }
      end

      # Gets array of all using props with their indexes
      # @return [Array] zip of real properties to their indexes
      def props_with_indexes
        @_props_with_indexes ||= props.map.with_index { |prop, i| [i, prop] }
      end

      # @return [Set]
      def all_props
        @_app_props ||= @described_props + @unrelevanted_props +
          @over_danglings_props + @over_relevants_props
      end

      # Adds default atoms of all used lattices
      def add_default_latticed_atoms
        default_latticed_atoms.each { |prop| store_prop(@described_props, prop) }
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

      # Stores all derived properties which can be gotten by passed method name
      # @param [Symbol] method_name by which the derived props can be gotten
      def store_all(method_name, prop)
        next_prop = prop
        while (next_prop = next_prop.public_send(method_name))
          store_prop(@over_danglings_props, next_prop)
        end
      end

      # Stores passed prop and it over props to internal sets
      # @param [Set] props_set the target set where props will be stored
      # @param [AtomProperties] prop the storing properties
      def store_prop(props_set, prop)
        store_and_drop_cache(props_set, prop)
        store_to(@over_relevants_props, prop.incoherent) unless prop.incoherent?
        store_to(@unrelevanted_props, prop.unrelevanted)
      end

      # Stores atom properties and drops the internal cache of all properties
      # @param [AtomProperties] prop the storing properties
      # @param [Set] props_set the target set where props will be stored
      def store_and_drop_cache(props_set, prop)
        props_set << detect_prop(prop)
        reset_caches!
      end

      # Stores passed prop and it unrelevanted analog to some set of properties
      # @param [AtomProperties] prop the storing properties
      # @param [Set] props_set the target set where props will be stored
      def store_to(props_set, prop)
        store_and_drop_cache(props_set, prop) unless not_nil_stored?(prop)
      end

      # Detects that passing atom properties already add
      # @param [AtomProperties] prop the  atom properties search patern or nil
      # @return [Boolean] was added or not
      def not_nil_stored?(prop)
        !prop || over_all_props(:any?, prop)
      end

      # Detects analogies atom properties
      # @param [AtomProperties] prop the  atom properties search patern or nil
      # @return [AtomProperties] analogies atom properties from internal value or nil
      def detect_prop(prop)
        over_all_props(:find, prop) || prop
      end

      # Applies passed method for detect some value on all properties set
      # @param [AtomProperties] prop the  atom properties search patern
      # @return [Object] the result of passing method
      def over_all_props(method_name, prop)
        all_props.send(method_name) { |x| prop == x }
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

      def reset_caches!
        @_app_props, @_props, @_props_hash = nil
      end
    end

  end
end
