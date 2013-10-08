using VersatileDiamond::Patches::RichArray

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
          return false unless atom_name == other.atom_name &&
            lattice == other.lattice

          oth_rels = other.relations.dup
          relations.all? { |rel| oth_rels.delete_one(rel) } &&
            (!has_relevants? || (other.has_relevants? &&
              !relevants.include?(:incoherent) &&
              (!relevants.include?(:unfixed) ||
                other.relevants.include?(:unfixed))))
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
          @size = 1 + (lattice ? 0.5 : 0) + relations.size +
            (relevants ? relevants.size * 0.34 : 0)
        end

        # Checks that contains relevants properties
        # @return [Boolean] contains or not
        def has_relevants?
          !!@has_relevants
        end

        def to_s
          rl = relations.dup
          name = atom_name.to_s

          while rl.delete_one(:active)
            name = "*#{name}"
          end

          while rl.delete_one { |r| r.is_a?(Position) }
            name = "#{name}."
          end

          if relevants
            relevants.each do |sym|
              suffix = case sym
                when :incoherent then 'i'
                when :unfixed then 'u'
              end
              name = "#{name}:#{suffix}"
            end
          end

          name = "#{name}%#{lattice.name}" if lattice

          down1 = rl.delete_one(bond_cross_110)
          down2 = rl.delete_one(bond_cross_110)
          if down1 && down2
            name = "#{name}<"
          elsif down1 || down2
            name = "#{name}/"
          elsif rl.delete_one(:tbond)
            name = "#{name}≡"
          elsif rl.delete_one(:dbond)
            name = "#{name}="
          elsif rl.delete_one(undirected_bond)
            name = "#{name}~"
          end

          up1 = rl.delete_one(bond_front_110)
          up2 = rl.delete_one(bond_front_110)
          if up1 && up2
            name = ">#{name}"
          elsif up1 || up2
            name = "^#{name}"
          elsif rl.delete_one(:dbond)
            name = "=#{name}"
          end

          if rl.delete_one(bond_front_100)
            name = "-#{name}"
          end

          while rl.delete_one(undirected_bond)
            name = "~#{name}"
          end

          name
        end

      protected

        attr_reader :props

        %w(atom_name lattice relations relevants).each_with_index do |name, i|
          define_method(name) { @props[i] }
        end

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
                links.delete_one(atom_rel)
              else
                relations << :dbond
              end
              links.delete_one(atom_rel)
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

        # if spec is specific spec then necessary to save all limit incoherent
        # states
        return unless spec.is_a?(SpecificSpec)
        # before, cast all atoms to specific atoms
        spec_dup = spec.dup
        spec_dup.links.keys.each do |atom|
          unless atom.is_a?(SpecificAtom)
            spec_dup.describe_atom(
              spec_dup.keyname(atom), SpecificAtom.new(atom))
          end
        end

        # storing all limit incoherent states
        spec_dup.links.each do |atom, _|
          atom.incoherent! if !atom.incoherent? &&
            spec_dup.external_bonds_for(atom) > 0

          prop = AtomProperties.new(spec_dup, atom)
          next if index(prop)
          @props << prop
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
      # @option [Spec | SpecificSpec] :without do not classify atoms like as
      #   from passed spec
      # @return [Hash] result of classification
      def classify(spec, without: nil)
        atoms = spec.links.keys

        if without
          without_same = spec.class.new(spec.name)
          parent_atoms = without.links.keys
          atoms = atoms.select do |atom|
            prop = AtomProperties.new(spec, atom)
            parent_atoms.all? do |parent_atom|
              parent_prop = AtomProperties.new(without, parent_atom)
              prop != parent_prop
            end
          end
        end

        atoms.each_with_object({}) do |atom, hash|
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
