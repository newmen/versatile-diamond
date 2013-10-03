module VersatileDiamond
  module Tools

    # Classifies atoms in specs and associate each atom type with some value,
    # which will be used for detecting overlapping specs between each other
    # and generates optimal specs search algorithm (after some reaction has
    # been realised) for updating of real specs set
    class AtomClassifier

      # Accumulates information about atom
      class AtomProperties
        include Modules::ListsComparer
        include Lattices::BasicRelations

        attr_reader :smallests

        # Overloaded constructor that stores all properties of atom
        # @overload new(props)
        #   @param [Array] props the array of default properties
        # @overload new(spec, atom)
        #   @param [Spec | SpecificSpec] spec in which atom will find properties
        #   @param [Atom | AtomReference | SpecificAtom] atom the atom for which
        #     properties will be stored
        def initialize(*args)
          if args.size == 1
            @props = args.first
          elsif args.size == 2
            spec, atom = args
            @props = [atom.name, atom.lattice, relations_for(spec, atom)]

            if atom.is_a?(SpecificAtom) && !atom.relevants.empty?
              @props << atom.relevants
              @has_relevants = true
            end
          else
            raise ArgumentError
          end
        end

        # Deep compares two properties by all properties
        # @param [AtomProperties] other an other atom properties
        # @return [Boolean] equal or not
        def == (other)
          lists_are_identical?(props, other.props) do |v, w|
            if v.is_a?(Array) && w.is_a?(Array)
              lists_are_identical?(v, w) { |a, b| a == b }
            else
              v == w
            end
          end
        end

        def contained_in?(other)
          return false unless props[0] == other.props[0] &&
            props[1] == other.props[1]

          oth_rels = other.props[2].dup
          props[2].all? { |rel| remove_one(oth_rels, rel) } &&
            (!has_relevants? || (other.has_relevants? &&
              (oth_vns = other.props[3].dup) &&
              props[3].all? { |vn| remove_one(oth_vns, vn) }))
        end

        # Adds dependency from smallest properties
        # @param [AtomProperties] smallest the smallest properties from which
        #   depends current
        def add_smallest(smallest)
          @smallests ||= Set.new
          @smallests -= smallest.smallests if smallest.smallests
          @smallests << smallest
        end

        # Makes unrelevanted copy of self
        # @return [AtomProperties] unrelevanted atom properties
        def unrelevanted
          self.class.new(wihtout_relevants)
        end

        # Gets size of properties
        def size
          return @size if @size
          _, lattice, relations, res = @props
          @size = 1 + (lattice ? 0.5 : 0) + relations.size +
            (res ? res.size * 0.34 : 0)
        end

        # Checks that contains relevants properties
        # @return [Boolean] contains or not
        def has_relevants?
          !!@has_relevants
        end

        def to_s
          name, lattice, relations, res = @props
          rl = relations.dup

          while remove_one(rl, :active)
            name = "*#{name}"
          end

          while remove_one(rl) { |r| r.is_a?(Position) }
            name = "#{name}."
          end

          if res
            res.each do |sym|
              suffix = case sym
                when :incoherent then 'i'
                when :unfixed then 'u'
              end
              name = "#{name}:#{suffix}"
            end
          end

          name = "#{name}%#{lattice.name}" if lattice

          down1 = remove_one(rl, bond_cross_110)
          down2 = remove_one(rl, bond_cross_110)
          if down1 && down2
            name = "#{name}<"
          elsif down1 || down2
            name = "#{name}/"
          elsif remove_one(rl, :tbond)
            name = "#{name}≡"
          elsif remove_one(rl, :dbond)
            name = "#{name}="
          elsif remove_one(rl, undirected_bond)
            name = "#{name}~"
          end

          up1 = remove_one(rl, bond_front_110)
          up2 = remove_one(rl, bond_front_110)
          if up1 && up2
            name = ">#{name}"
          elsif up1 || up2
            name = "^#{name}"
          elsif remove_one(rl, :dbond)
            name = "=#{name}"
          end

          if remove_one(rl, bond_front_100)
            name = "-#{name}"
          end

          while remove_one(rl, undirected_bond)
            name = "~#{name}"
          end

          name
        end

      protected

        attr_reader :props

      private

        # Harvest relations of atom in spec
        # @param [Spec | SpecificSpec] spec see at #new same argument
        # @param [Atom | AtomReference | SpecificAtom] spec see at #new same
        #   argument
        def relations_for(spec, atom)
          relations = []
          links = atom.relations_in(spec)
          until links.empty?
            atom_rel = links.pop

            if atom_rel.is_a?(Symbol)
              relations << atom_rel
              next
            end

            same = links.select { |ar| ar == atom_rel }

            if !same.empty?
              if same.size == 3 && same.size != 4
                relations << :tbond
                links.delete_at(links.index(atom_rel) || links.size)
              else
                relations << :dbond
              end
              links.delete_at(links.index(atom_rel) || links.size)
            else
              relations << atom_rel.last
            end
          end
          relations
        end

        # Drops relevants properties if it exists
        # @return [Array] properties without relevants
        def wihtout_relevants
          has_relevants? ? props[0...(props.length - 1)] : props
        end

        # Removes one item from list
        # @param [Array] list the list of items
        # @param [Object] item some item from list
        # @yeild [Object] if passed instead of item then finds index of item
        # @return [Object] removed object
        # TODO: very useful method
        def remove_one(list, item = nil, &block)
          index = item && !block_given? ?
            list.index(item) :
            block_given? ? list.index(&block) : (raise ArgumentError)

          list.delete_at(index || list.size)
        end
      end

      # Initialize a classifier by set of properties
      def initialize
        @props = []
        @unrelevanted_props = Set.new
      end

      # Provides each iterator for all properties
      # @yield [AtomProperties] do something with each properties
      # @return [Enumerator] if block is not given
      def each_props(&block)
        block_given? ? @props.each(&block) : @props.each
      end

      # Analyze spec and store all uniq properties
      # @param [Spec | SpecificSpec] spec the analyzing spec
      def analyze(spec)
        spec.links.each do |atom, _|
          prop = AtomProperties.new(spec, atom)
          next if index(prop)
          @props << prop

          unrel_prop = prop.unrelevanted
          @props << unrel_prop unless index(unrel_prop)

          next if @unrelevanted_props.find { |p| p == unrel_prop }
          @unrelevanted_props << unrel_prop
        end
      end

      # Organizes dependencies between properties
      def organize_properties!
        props = @props.sort_by(&:size)
        until props.empty?
          smallest = props.shift
          props.each do |prop|
            next unless smallest.contained_in?(prop)
            prop.add_smallest(smallest)
          end
        end
      end

      # Classify spec and return hash where keys is order number of property
      # and values is number of atoms in spec with same properties
      #
      # @param [Spec | SpecificSpec] spec the analyzing spec
      # @return [Hash] result of classification
      # TODO: rspec it!
      def classify(spec)
        spec.links.keys.each_with_object({}) do |atom, hash|
          prop = AtomProperties.new(spec, atom)
          index = index(prop)
          image = prop.to_s
          hash[index] ||= [image, 0]
          hash[index][1] += 1
        end
      end

      # Finds index of passed property
      # @overloaded index(prop)
      #   @param [AtomProperties] prop the property index of which will be found
      # @overloaded index(spec, atom)
      #   @param [Spec | SpecificSpec] spec the spec for which properties of
      #     atom will be found
      #   @param [Atom | AtomReference | SpecificAtom] atom the atom for which
      #     properties will be found
      # @return [Integer] the index of properties or nil
      def index(*args)
        prop =
          if args.size == 1
            args.first
          elsif args.size == 2
            AtomProperties.new(*args)
          else
            raise ArgumentError
          end
        @props.index(prop)
      end

      # Gets number of all different properties
      # @return [Integer] quantity of all uniq properties
      def all_types_num
        @props.size
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
        @props[index].has_relevants?
      end
    end

  end
end
