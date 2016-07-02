module VersatileDiamond
  module Organizers

    # Classifies atoms in specs and associate each atom type with some value,
    # which will be used for detecting overlapping specs between each other
    # and generates optimal specs search algorithm (after some reaction has
    # been realised) for updating of real specs set
    class AtomClassifier

      # Initialize a classifier by empty sets of properties
      # @param [Array] danglings the list of termination species
      def initialize(danglings = [])
        @danglings = danglings

        @described_props = Set.new
        @over_danglings_props = Set.new
        @over_relevants_props = Set.new
        @unrelevanted_props = Set.new

        @_default_latticed_atoms = nil
        @_atomic_dangling = nil
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
      def analyze!(spec)
        raise 'Cache of properties already created' if @_props_with_indexes

        avail_props = spec.links.keys.map { |atom| AtomProperties.new(spec, atom) }
        avail_props.each do |prop|
          store_prop(@described_props, prop)
          append_danglings!(prop) unless @danglings.empty?
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
            raise ArgumentError, "Wrong number of arguments: #{args.inspect}"
          end
        props_hash.key(prop)
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
        props.map(&method(:specificate)).map(&method(:index))
      end

      # Gets transitions array of actives atoms to notactives
      # @return [Array] the transitions array
      def actives_to_deactives
        collect_transitions(&:deactivated)
      end

      # Gets transitions array of notactives atoms to actives
      # @return [Array] the transitions array
      def deactives_to_actives
        collect_transitions(&:activated)
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
          used_lattices.compact.flat_map do |lattice|
            %w(major surface).map do |name|
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
          (prop == smallest && prop.relevant?) ||
          (prop != smallest && is?(prop, smallest) &&
                      (prop.incoherent? || most_bigger?(prop)))
        end
      end

      def inspect
        props_with_index = props.map.with_index
        items = props_with_index.map { |pr, i| "#{i.to_s.rjust(7)}:  #{pr}\n" }
        "{\n#{items.join}}"
      end

    private

      ACTIVE_BOND = AtomProperties::ACTIVE_BOND

      # Checks that passed atom properties haven't most bigger
      # @param [AtomProperties] bigger atom properties which will be checked
      # @return [Boolean] is most bigger or not
      def most_bigger?(bigger)
        !props.any? { |prop| prop != bigger && is?(prop, bigger) }
      end

      # @return [Boolean] is any stored properties defined or not?
      def incoherent_defined?
        return @_is_incoherent_defined unless @_is_incoherent_defined.nil?
        @_is_incoherent_defined = props.any?(&:incoherent?)
      end

      # @return [Boolean] are required relative states or not
      def relatives_required?
        @danglings.empty? && incoherent_defined?
      end

      # Gets array of all using props with their indexes
      # @return [Array] zip of real properties to their indexes
      def props_with_indexes
        @_props_with_indexes ||= props.map.with_index { |prop, i| [i, prop] }
      end

      # @return [Set]
      def all_props
        @_all_props ||= @described_props + @unrelevanted_props +
          @over_danglings_props + @over_relevants_props
      end

      # Adds default atoms of all used lattices
      def add_default_latticed_atoms
        default_latticed_atoms.each { |prop| store_prop(@described_props, prop) }
      end

      # Iterates available dangling species and extends the total set of properties
      # @param [AtomProperties] prop which extended analogies will be stored too
      def append_danglings!(prop)
        checking_props = [prop]
        until checking_props.empty?
          cp = checking_props.shift
          @danglings.each do |termination|
            checking_props += store_all(cp, termination, &:add_dangling)
            checking_props += store_all(cp, termination, &:remove_dangling)
          end
        end
      end

      # Organizes dependencies between atom properties by checking inclusion
      # @param [Array] props_list the observing atom properties
      def organize_by_inclusion!(props_list)
        group_props_list(props_list, &:contained_in?).each do |big, smallests|
          smallests.each do |small|
            big.add_smallest(small) unless deep_same?(big, small)
          end
        end
      end

      # Organizes dependencies between atom properties by checking relative states
      # @param [Array] props_list the observing atom properties
      def organize_by_relatives!(props_list)
        group_props_list(props_list, &method(:relevant_same?)).each do |big, smallests|
          smallests.each do |small|
            big.add_same(small) unless deep_same?(big, small)
          end
        end
      end

      # @param [AtomProperties] small
      # @param [AtomProperties] big
      # @return [Boolean] is big relevant states are same as in small
      def relevant_same?(small, big)
        !small.contained_in?(big) &&
          (big.same_incoherent?(small) || big.same_unfixed?(small))
      end

      # @param [AtomProperties] big atom properties which children will be checked
      # @param [AtomProperties] small atom properties which will be compared with each
      #   child properties of big
      # @return [Boolean] is big already has small as same
      def deep_same?(big, small)
        children = big.sames + big.smallests
        !children.empty? &&
          children.any? { |child| child == small || deep_same?(child, small) }
      end

      # Groups passed list of atom properties
      # @param [Array] props_list the iterating atom properties
      # @yield [AtomProperties, AtomProperties] do with bigger and smallest atom
      #   properties which should be compared by
      def group_props_list(props_list, &block)
        result = []
        props_list_dup = props_list.sort
        until props_list_dup.empty?
          big = props_list_dup.pop
          smallests = props_list_dup.select { |small| block[small, big] }
          result << [big, smallests.sort.reverse]
        end
        result.sort_by(&:first)
      end


      # Stores all derived properties which can be gotten by passed method name
      # @param [AtomProperties] prop which extended copies will be stored
      # @param [Concepts::TerminationSpec] termination spec by which the property
      #   copies will be created
      # @yield [AtomProperties] by which the derived props can be gotten
      # @return [Array] the list of added nodes
      def store_all(prop, termination, &block)
        result = []
        # relevants = Set.new
        next_prop = prop
        loop do
          next_prop = block[next_prop, termination]
          return result unless next_prop
          next if next_prop.relevant? #&& !relevants.include?(next_prop)
        #     # relevants << next_prop
          unless @over_danglings_props.include?(next_prop)
            store_prop(@over_danglings_props, next_prop)
            result << next_prop
          end
        end
      end

      # Stores passed prop and it over props to internal sets
      # @param [Set] props_set the target set where props will be stored
      # @param [AtomProperties] prop the storing properties
      def store_prop(props_set, prop)
        return if props_set.include?(prop)
        store_and_drop_cache(props_set, prop)
        store_to(@unrelevanted_props, prop.unrelevanted)
        if !prop.incoherent? && relatives_required?
          store_to(@over_relevants_props, prop.incoherent)
        end
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
        !prop || over_all_props(prop, &:any?)
      end

      # Detects analogies atom properties
      # @param [AtomProperties] prop the  atom properties search patern or nil
      # @return [AtomProperties] analogies atom properties from internal value or nil
      def detect_prop(prop)
        over_all_props(prop, &:find) || prop
      end

      # Applies passed method for detect some value on all properties set
      # @param [AtomProperties] prop the  atom properties search patern
      # @yield [Array] applies to all atom properties list
      # @return [Object] the result of passing method
      def over_all_props(prop, &block)
        block.call(all_props) { |x| prop == x }
      end

      # Collects transitions array by passed method name
      # @yield [AtomProperties] produce new properties
      # @return [Array] collected array
      def collect_transitions(&block)
        props.map do |prop|
          trans_prop = block[prop, atomic_dangling]
          target_prop = trans_prop && not_nil_stored?(trans_prop) ? trans_prop : prop
          index(specificate(target_prop))
        end
      end

      # Gets the atomic dangling if there is just one this dangling
      # @return [DependentTermination] another used termiation dangling atomic spec
      def atomic_dangling
        if @_atomic_dangling.nil?
          another_danglings = props.flat_map(&:danglings).uniq - [ACTIVE_BOND]
          @_atomic_dangling = another_danglings.one? ? another_danglings.first : false
        else
          @_atomic_dangling == false ? nil : @_atomic_dangling
        end
      end

      # @param [AtomProperties] prop which will be specified
      # @return [AtomProperties] the end point fo atom properties dependencies graph
      def specificate(prop)
        small_next = smallests_transitive_matrix.specification_for(prop)
        gen_next = general_transitive_matrix.specification_for(prop)
        [small_next, gen_next].sort.last
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
        @_all_props, @_props, @_props_with_indexes, @_props_hash = nil
        @_is_incoherent_defined = nil
        @_tmatrix, @_st_matrix = nil
      end
    end

  end
end
