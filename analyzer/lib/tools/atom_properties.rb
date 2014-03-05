using VersatileDiamond::Patches::RichArray
using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Tools

    # Accumulates information about atom
    class AtomProperties
      include Modules::ListsComparer
      include Lattices::BasicRelations

      attr_reader :smallests, :sames

      # Stores all properties of atom
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
            relations_for(spec, atom),
            danglings_for(spec, atom)
          ]

          if atom.is_a?(SpecificAtom) && !atom.relevants.empty?
            @props << atom.relevants
          end
        else
          raise ArgumentError, 'Wrong number of arguments'
        end
      end

      # Deep compares two properties by all properties
      # @param [AtomProperties] other an other atom properties
      # @return [Boolean] equal or not
      def == (other)
        same_basic_values?(other) && eq_relations?(other) &&
          eq_danglings?(other) && eq_relevants?(other)
      end

      # Checks that current properties contained in another properties
      # @param [AtomProperties] other probably parent atom properties
      # @return [Boolean] contained or not
      def contained_in?(other)
        same_basic_values?(other) && contain_all_bonds?(other) &&
          same_correspond_relations?(other)
      end

      # Checks that other properties has same incoherent state
      # @param [AtomProperties] other probably same properties by incoherent
      #   state
      # @return [Boolean] same or not
      def same_incoherent?(other)
        same_basic_values?(other) && !danglings.empty? && other.incoherent? &&
          other.contain_all_danglings?(self) && eq_relations?(other) &&
          (bonds_num == valence || eq_relevants?(other))
      end

      # Gives the number of how many termination specs lies in current
      # properties
      #
      # @param [TerminationSpec] term_spec the verifiable termination spec
      # @raise [ArgumentError] if argument is not termination spec
      # @return [Boolean] have or not
      def terminations_num(term_spec)
        if term_spec.class == ActiveBond
          actives_num
        elsif term_spec.class == AtomicSpec
          if term_spec.is_hydrogen?
            total_hydrogens_num
          else
            count_danglings(term_spec.name)
          end
        else
          raise ArgumentError, 'Undefined termination spec type'
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
        if valence > bonds_num && !incoherent?
          props = wihtout_relevants
          new_rel = [:incoherent]
          new_rel << :unfixed if estab_bonds_num == 1
          props << new_rel
          self.class.new(props)
        else
          nil
        end
      end

      # Are properties contain relevant values
      # @return [Boolean] contain or not
      def relevant?
        !!relevants
      end

      # Gets property same as current but activated
      # @return [AtomProperties] activated properties or nil
      def activated
        if valence > bonds_num
          props = [*static_states, relations, danglings + [:active]]
          props << relevants.dup if relevants && valence > bonds_num + 1
          self.class.new(props)
        else
          nil
        end
      end

      # Gets property same as current but deactivated
      # @return [AtomProperties] deactivated properties or nil
      def deactivated
        dgs = danglings.dup
        if dgs.delete_one(:active)
          props = [*static_states, relations.dup, dgs]
          props << relevants if relevants
          self.class.new(props)
        else
          nil
        end
      end

      # Gets size of properties
      # @return [Integer] the size of properties
      def size
        return @size if @size
        @size = valence + (lattice ? 0.5 : 0) +
          estab_bonds_num + positions_num +
          danglings.size * 0.34 +
          (relevants ? relevants.size * 0.21 : 0)
      end

      # Convert properties to string representation
      # @return [String] the string representaion of properties
      def to_s
        name = atom_name.to_s

        dg = danglings.dup
        while dg.delete_one(:active)
          name = "*#{name}"
        end

        while (monovalent_atom = dg.pop)
          name = "#{monovalent_atom}#{name}"
        end

        rl = relations.dup
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

      # Define human named methods for accessing to props
      %w(
        atom_name
        valence
        lattice
        relations
        danglings
        relevants
      ).each_with_index do |name, i|
        define_method(name) { @props[i] }
      end
      public :lattice

      # The static states of properties
      # @return [Array] the array of static states
      def static_states
        props[0..2]
      end

      # Checks that other properties contain all current danglings
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def contain_all_danglings?(other)
        contain_all_by?(other, :danglings)
      end

      # Gets number of hydrogen atoms
      # @return [Integer] number of active bonds
      def dangling_hydrogens_num
        count_danglings(:H)
      end

    private

      # Compares with other properties by some method which returns list
      # @param [AtomProperties] other the comparing properties
      # @param [Symbol] method by which will be comparing
      # @return [Boolean] lists are equal or not
      def eq_by?(other, method)
        lists_are_identical?(send(method), other.send(method)) do |a, b|
          a == b
        end
      end

      # Compares current relations with other relations
      # @param [AtomProperties] other the comparing properties
      # @return [Boolean] lists are equal or not
      def eq_relations?(other)
        eq_by?(other, :relations)
      end

      # Compares current danglings with other danglings
      # @param [AtomProperties] other the comparing properties
      # @return [Boolean] lists are equal or not
      def eq_danglings?(other)
        eq_by?(other, :danglings)
      end

      # Compares current relevant states with other relevant states
      # @param [AtomProperties] other the comparing properties
      # @param [Symbol] method by which will be comparing
      # @return [Boolean] lists are equal or not
      def eq_relevants?(other)
        return true if !relevants && !other.relevants
        relevants && other.relevants && eq_by?(other, :relevants)
      end

      # Compares basic values of two properties
      # @peram [AtomProperties] other the comparing properties
      # @return [Boolean] same or not
      def same_basic_values?(other)
        static_states == other.static_states
      end

      # Checks that other properties contain all bonds from current properties
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def contain_all_bonds?(other)
        contain_all_relations?(other) && contain_all_danglings?(other)
      end

      # Checks that other properties contain all current relations
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def contain_all_relations?(other)
        contain_all_by?(other, :relations)
      end

      # Checks that other properties contain all current states that go by some
      # method
      #
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def contain_all_by?(other, method)
        oth_stats = other.send(method).dup
        send(method).all? { |rel| oth_stats.delete_one(rel) }
      end

      # Checks that other properties is incoherent and it is same as current
      # properties by hydrogen atom nums
      #
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] other is incoherent and contain same hydrogen nums or
      #   not
      def same_by_hydrogens?(other)
        incoherent? && contain_all_by?(other, :danglings_wo_hydrogens) &&
          total_hydrogens_num == other.dangling_hydrogens_num
      end

      # Checks that other properties contain relevant states from current
      # properties
      #
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def same_correspond_relations?(other)
        return false if relevants && !other.relevants
        return true if !relevants
        !relevants.include?(:incoherent) && other.relevants.include?(:unfixed)
      end

      # Harvest relations of atom in spec
      # @param [Spec | SpecificSpec] spec see at #new same argument
      # @param [Atom | AtomReference | SpecificAtom] spec see at #new same
      #   argument
      # @return [Array] relations array
      def relations_for(spec, atom)
        relations = []
        links = atom.relations_in(spec).reject { |ar| ar.is_a?(Symbol) }
        until links.empty?
          atom_rel = links.pop
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

      # Harvest dangling bonds of atom in spec
      # @param [Spec | SpecificSpec] spec see at #new same argument
      # @param [Atom | AtomReference | SpecificAtom] spec see at #new same
      #   argument
      # @return [Array] dangling states array
      def danglings_for(spec, atom)
        links = atom.relations_in(spec)
        links.reduce([]) do |acc, atom_rel|
          atom_rel.is_a?(Symbol) ? acc + [atom_rel] : acc
        end
      end

      # Drops relevants properties if it exists
      # @return [Array] properties without relevants
      def wihtout_relevants
        relevants ? props[0...(props.length - 1)] : props
      end

      # Counts relations that is a instance of passed class
      # @param [Class] klass the class of counting instances
      # @return [Integer] the number of relations
      def count_relations(klass)
        relations.select { |r| r.class == klass }.size
      end

      # Gets number of established bond relations
      # @return [Integer] the number of established bond relations
      def estab_bonds_num
        count_relations(Bond) +
          (relations.include?(:dbond) ? 2 : 0) +
          (relations.include?(:tbond) ? 3 : 0)
      end

      # Gets number of position relations
      # @return [Integer] the number of position relations
      def positions_num
        count_relations(Position)
      end

      # Gets number of established and dangling bond relations
      # @return [Integer] the total number of bonds
      def bonds_num
        estab_bonds_num + danglings.size
      end

      # Counts of dangling instances
      # @param [Symbol] state the counting state
      # @return [Integer] number of instances
      def count_danglings(state)
        danglings.select { |r| r == state }.size
      end

      # Gets number of active bonds
      # @return [Integer] number of active bonds
      def actives_num
        count_danglings(:active)
      end

      # Counts total number of hydrogen atoms
      # @return [Integer] the number of total number of hydrogen atoms
      def total_hydrogens_num
        valence - bonds_num + dangling_hydrogens_num
      end

      # Gets danglings without hydrogen atoms
      # @return [Array] the array of danglings without hydrogen atoms
      def danglings_wo_hydrogens
        danglings.reject { |d| d == :H }
      end
    end

  end
end
