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

            if atom.is_a?(SpecificAtom)
              @props << atom.relevants
              @has_relevants = true
            end
          else
            raise ArgumentsError
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

        # Makes unrelevanted copy of self
        # @return [AtomProperties] unrelevanted atom properties
        def unrelevanted
          self.class.new(wihtout_relevants)
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
            name = "#{name}\\"
          elsif remove_one(rl, :dbond)
            name = "#{name}="
          elsif remove_one(rl, undirected_bond)
            name = "#{name}-"
          end

          up1 = remove_one(rl, bond_front_110)
          up2 = remove_one(rl, bond_front_110)
          if up1 && up2
            name = ">#{name}"
          elsif up1 || up2
            name = "\\#{name}"
          elsif remove_one(rl, :dbond)
            name = "=#{name}"
          end

          while remove_one(rl, undirected_bond)
            name = "-#{name}"
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
              links.delete_at(links.index(atom_rel) || links.size)
              relations << :dbond
            else
              relations << atom_rel.last
            end
          end
          relations
        end

        # Drops relevants properties if it exists
        # @return [Array] properties without relevants
        def wihtout_relevants
          @has_relevants ? props[0...(props.length - 1)] : props
        end

        # Removes one item from list
        # @param [Array] list the list of items
        # @param [Object] item some item from list
        # @yeild [Object] if passed instead of item then finds index of item
        # @return [Object] removed object
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

      # Analyze spec and store all uniq properties
      # @param [Spec | SpecificSpec] spec the analyzing spec
      def analyze(spec)
        spec.links.each do |atom, _|
          prop = AtomProperties.new(spec, atom)
          next if find_prop_index(prop)
          @props << prop

          unrel_prop = prop.unrelevanted
          next if @unrelevanted_props.find { |p| p == unrel_prop }
          @unrelevanted_props << unrel_prop
        end
      end

      # Classify spec and return hash where keys is order number of property
      # and values is number of atoms in spec with same properties
      #
      # @param [Spec | SpecificSpec] spec the analyzing spec
      # @return [Hash] result of classification
      def classify(spec)
        spec.links.keys.each_with_object({}) do |atom, hash|
          prop = AtomProperties.new(spec, atom)
          image = "%3s : %7s" % [find_prop_index(prop), prop.to_s]
          hash[image] ||= 0
          hash[image] += 1
        end
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

    private

      # Finds index of passed property
      # @param [AtomProperties] prop the property index of which will be found
      # @return [Integer] the index of property or nil
      def find_prop_index(prop)
        @props.index { |p| p == prop }
      end
    end

  end
end
