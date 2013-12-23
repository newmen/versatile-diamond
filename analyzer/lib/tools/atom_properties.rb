using VersatileDiamond::Patches::RichArray
using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Tools

    # Accumulates information about atom
    class AtomProperties
      include Modules::ListsComparer
      include Lattices::BasicRelations

      attr_reader :smallests, :sames

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
          @props = [
            atom.name,
            atom.original_valence,
            atom.lattice,
            relations_for(spec, atom)
          ]

          if atom.is_a?(SpecificAtom) && !atom.relevants.empty?
            @props << atom.relevants
          end
        else
          raise ArgumentError
        end
      end

      # Define human named methods for accessing to props
      %w(
        atom_name
        valence
        lattice
        relations
        relevants
      ).each_with_index do |name, i|
        define_method(name) { @props[i] }
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

      # Checks that current properties contained in another properties
      # @param [AtomProperties] other probably parent atom properties
      # @return [Boolean] contained or not
      def contained_in?(other)
        return false unless same_basic_values?(other)

        oth_rels = other.relations.dup
        relations.all? { |rel| oth_rels.delete_one(rel) } &&
          (!relevants || (other.relevants &&
            !relevants.include?(:incoherent) &&
            (!relevants.include?(:unfixed) ||
              other.relevants.include?(:unfixed))))
      end

      # Checks that other properties has same incoherent state
      # @param [AtomProperties] other probably same properties by incoherent
      #   state
      # @return [Boolean] same or not
      def same_incoherent?(other)
        return false unless same_basic_values?(other) && active? &&
          other.relevants && other.relevants.include?(:incoherent) &&
          !contained_in?(other)

        lists_are_identical?(
          relations_wo_actives, other.relations_wo_actives) { |a, b| a == b } &&
          actives_num > other.actives_num &&
          (bonds_num == valence || (relevants &&
            lists_are_identical?(relevants, other.relevants) { |a, b| a == b }))
      end

      # Gives the number of how many termination specs lies in current
      # properties
      #
      # @param [TerminationSpec] term_spec the verifiable termination spec
      # @return [Boolean] have or not
      def terminations_num(term_spec)
        case term_spec.class.to_s.underscore
        when 'active_bond'
          actives_num
        when 'atomic_spec'
          if term_spec.is_hydrogen?
            valence - bonds_num
          else
            (valence == 1 && atom_name == term_spec.name) ? 1 : 0
          end
        else
          raise 'Undefined termination spec type'
        end
      end

      # Adds dependency from smallest properties
      # @param [AtomProperties] smallest the smallest properties from which
      #   depends current
      def add_smallest(smallest)
        @smallests ||= Set.new
        @smallests -= smallest.smallests if smallest.smallests
        @smallests << smallest
      end

      # Adds dependency from same properties by incoherent state
      # @param [AtomProperties] same the same properties from which depends
      #   current properties
      def add_same(same)
        @sames ||= Set.new
        @sames << same
      end

      # Makes unrelevanted copy of self
      # @return [AtomProperties] unrelevanted atom properties
      def unrelevanted
        self.class.new(wihtout_relevants)
      end

      # Has incoherent property or not
      # @return [Boolean] contain or not
      def incoherent?
        relevants && relevants.include?(:incoherent)
      end

      # Makes incoherent copy of self
      # @return [AtomProperties] incoherented atom properties or nil
      def incoherent
        if valence > bonds_num && (!relevants || !incoherent?)
          props = wihtout_relevants
          new_rel = [:incoherent]
          new_rel + relevants if relevants
          props << new_rel
          self.class.new(props)
        else
          nil
        end
      end

      # Are properties contain active
      # @return [Boolean] contain or not
      def active?
        relations.include?(:active)
      end

      # Gets property same as current but activated
      # @return [AtomProperties] activated properties or nil
      def activated
        if valence > bonds_num
          props = [atom_name, valence, lattice, relations + [:active]]
          props << relevants.dup if relevants && valence > bonds_num + 1
          self.class.new(props)
        else
          nil
        end
      end

      # Gets property same as current but deactivated
      # @return [AtomProperties] deactivated properties or nil
      def deactivated
        r = relations.dup
        if r.delete_one(:active)
          props = [atom_name, valence, lattice, r]
          props << relevants if relevants
          self.class.new(props)
        else
          nil
        end
      end

      # Gets size of properties
      def size
        return @size if @size
        @size = valence + (lattice ? 0.5 : 0) + relations.size +
          (relevants ? relevants.size * 0.34 : 0)
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

      # Gets relations array without active bonds
      # @return [Array] the array of relations without active bonds
      def relations_wo_actives
        relations.reject { |r| r == :active }
      end

      # Gets number of active bonds
      # @return [Integer] number of active bonds
      def actives_num
        relations.select { |r| r == :active }.size
      end

    private

      # Compares basic values of two properties
      # @peram [AtomProperties] other the comparing properties
      # @return [Boolean] same or not
      def same_basic_values?(other)
        atom_name == other.atom_name && lattice == other.lattice
      end

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
        relevants ? props[0...(props.length - 1)] : props
      end

      # Gets number of bond relations
      # @return [Array] the array of bond relations
      def bonds_num
        relations.select { |r| r.class == Bond || r == :active }.size +
          (relations.include?(:dbond) ? 2 : 0) +
          (relations.include?(:tbond) ? 3 : 0)
      end
    end

  end
end
