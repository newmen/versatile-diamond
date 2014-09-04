module VersatileDiamond
  using Patches::RichArray
  using Patches::RichString

  module Organizers

    # Accumulates information about atom
    class AtomProperties
      include Modules::ListsComparer
      include Lattices::BasicRelations

      attr_reader :smallests, :sames

      # Stores all properties of atom
      # @overload new(props)
      #   @param [Array] props the array of default properties
      # @overload new(props)
      #   @param [Hash] props the hash of properties where each key is property method
      # @overload new(spec, atom)
      #   @param [DependentSpec | SpecResidual] spec in which atom will find properties
      #   @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #     atom the atom for which properties will be stored
      def initialize(*args)
        @_remake_result = nil

        if args.size == 1
          arg = args.first
          if arg.is_a?(Array)
            check_relevants(arg.last)
            @props = arg
          elsif arg.is_a?(Hash)
            @props = [
              arg[:atom_name] || raise('Undefined atom name'),
              arg[:valence] || raise('Undefined valence'),
              arg[:lattice] || raise('Undefined lattice'),
              arg[:relations] || raise('Undefined relations'),
              arg[:danglings] || [],
              arg[:nbr_lattices] || [],
              check_relevants(arg[:relevants] || [])
            ]
          else
            raise ArgumentError, 'Wrong type of argument'
          end
        elsif args.size == 2
          spec, atom = args
          @props = [
            atom.name,
            atom.original_valence,
            atom.lattice,
            relations_for(spec, atom),
            danglings_for(spec, atom),
            nbr_lattices_for(spec, atom),
            check_relevants(atom.relevants.dup)
          ]
        else
          raise ArgumentError, 'Wrong number of arguments'
        end
      end

      # Deep compares two properties by all properties
      # @param [AtomProperties] other an other atom properties
      # @return [Boolean] equal or not
      def == (other)
        same_basic_values?(other) &&
          [:relations, :danglings, :nbr_lattices, :relevants].all? do |name|
            eq_by?(other, name)
          end
      end

      # Checks that current properties includes another properties
      # @param [AtomProperties] other probably child atom properties
      # @return [Boolean] includes or not
      def include?(other)
        other.contained_in?(self) || same_incoherent?(other) || same_unfixed?(other)
      end

      # Checks that current properties contained in another properties
      # @param [AtomProperties] other probably parent atom properties
      # @return [Boolean] contained or not
      def contained_in?(other)
        same_basic_values?(other) && other.contain_all_bonds?(self) &&
          same_correspond_relevants?(other)
      end

      # Checks that both properties have same states by hydrogen atoms
      # @param [AtomProperties] other properties which will be checked
      # @return [Boolean] same or not
      def same_hydrogens?(other)
        total_hydrogens_num == other.total_hydrogens_num
      end

      # Checks that other properties have same incoherent state
      # @param [AtomProperties] other probably same properties by incoherent state
      # @return [Boolean] same or not
      def same_incoherent?(other)
        same_basic_values?(other) && (((incoherent? || bonds_num == valence) &&
              other.incoherent? && contain_all_danglings?(other)) ||
            (incoherent? && other.unfixed? && eq_danglings?(other))) &&
          eq_relations?(other) && eq_nbr_lattices?(other)
      end

      # Checks that other properties have same unfixed state
      # @param [AtomProperties] other probably same properties by unfixed state
      # @return [Boolean] same or not
      def same_unfixed?(other)
        same_basic_values?(other) &&
          !unfixed? && unfixed_by_nbrs? && other.unfixed? &&
          !incoherent? && eq_danglings?(other) &&
          contain_all_nbr_lattices?(other) && contain_all_relations?(other)
      end

      # Checks that current properties correspond to atom, lattice and have same
      # relations pack
      #
      # @param [Hash] info about checkable properties
      # @return [Boolean] is correspond or not
      def correspond?(info)
        info.all? do |key, value|
          internal_value = send(key)
          internal_value.is_a?(Array) ?
            lists_are_identical?(internal_value, value, &:==) :
            internal_value == value
        end
      end

      %w(smallest same).each do |name|
        var_name = :"@#{name}s"

        # Adds dependency from #{name} properties
        # @param [AtomProperties] stuff the #{name} properties from which
        #   depends current
        define_method(:"add_#{name}") do |stuff|
          var = instance_variable_get(var_name) ||
            instance_variable_set(var_name, Set.new)

          from_child = stuff.send(:"#{name}s")
          var.subtract(from_child) if from_child
          var << stuff
        end
      end

      # Makes unrelevanted copy of self
      # @return [AtomProperties] unrelevanted atom properties
      def unrelevanted
        self.class.new(without_relevants)
      end

      # Has incoherent state or not
      # @return [Boolean] contain or not
      def incoherent?
        relevants.include?(Incoherent.property)
      end

      # Makes incoherent copy of self
      # @return [AtomProperties] incoherented atom properties or nil
      def incoherent
        if valence > bonds_num && !incoherent?
          props = without_relevants
          props[-1] = [Incoherent.property]
          self.class.new(props)
        else
          nil
        end
      end

      # Are properties contain relevant values
      # @return [Boolean] contain or not
      def relevant?
        !relevants.empty?
      end

      # Gets property same as current but activated
      # @return [AtomProperties] activated properties or nil
      def activated
        if valence > bonds_num
          ext_dangs = danglings + [ActiveBond.property]
          props = [*static_states, relations, ext_dangs, nbr_lattices]
          props << (valence > bonds_num + 1 ? relevants : [])
          self.class.new(props)
        else
          nil
        end
      end

      # Gets property same as current but deactivated
      # @return [AtomProperties] deactivated properties or nil
      def deactivated
        dgs = danglings.dup
        if dgs.delete_one(ActiveBond.property)
          props = [*static_states, relations, dgs, nbr_lattices, relevants]
          self.class.new(props)
        else
          nil
        end
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
        count_danglings(ActiveBond.property)
      end

      # Gets the number of actives when each established bond replaced to active bond
      # @return [Integer] number of unbonded actives
      def unbonded_actives_num
        estab_bonds_num + actives_num
      end

      # Gets number of hydrogen atoms
      # @return [Integer] number of active bonds
      def dangling_hydrogens_num
        count_danglings(AtomicSpec.new(Concepts::Atom.hydrogen))
      end

      # Counts total number of hydrogen atoms
      # @return [Integer] the number of total number of hydrogen atoms
      def total_hydrogens_num
        valence - bonds_num + dangling_hydrogens_num
      end

      # Gets size of properties
      # @return [Integer] the size of properties
      def size
        return @size if @size
        @size = valence + (lattice ? 0.5 : 0) +
          estab_bonds_num + danglings.size * 0.34 +
          (incoherent? ? 0.13 : (unfixed? ? 0.05 : 0))
      end

      # Convert properties to string representation
      # @return [String] the string representaion of properties
      def to_s
        name = atom_name.to_s

        dg = danglings.dup
        name = "*#{name}" while dg.delete_one(ActiveBond.property)

        while (monovalent_atom = dg.pop)
          name = "#{monovalent_atom}#{name}"
        end

        if relevant?
          relevants.each do |suffix|
            name = "#{name}:#{suffix}"
          end
        end

        name = "#{name}%#{lattice.name}" if lattice

        nlts = nbr_lattices.dup
        lattice_symbol = -> rel do
          frl = nlts.find { |r, _| r == rel }
          if frl
            nlts.delete_one(frl)
            frl.last || '_'
          end
        end

        rl = relations.dup
        down1 = rl.delete_one(bond_cross_110)
        down2 = rl.delete_one(bond_cross_110)
        if down1 && down2
          name = "#{name}<"
        elsif down1 || down2
          name = "#{name}/"
        elsif rl.delete_one(:tbond)
          name = "#{name}≡#{lattice_symbol[:tbond]}"
        elsif rl.delete_one(:dbond)
          name = "#{name}=#{lattice_symbol[:dbond]}"
        elsif rl.delete_one(undirected_bond)
          name = "#{name}~#{lattice_symbol[undirected_bond]}"
        end

        up1 = rl.delete_one(bond_front_110)
        up2 = rl.delete_one(bond_front_110)
        if up1 && up2
          name = ">#{name}"
        elsif up1 || up2
          name = "^#{name}"
        elsif rl.delete_one(:dbond)
          name = "#{lattice_symbol[:dbond]}=#{name}"
        end

        name = "-#{name}" if rl.delete_one(bond_front_100)
        while rl.delete_one(undirected_bond)
          name = "#{lattice_symbol[undirected_bond]}~#{name}"
        end

        name
      end

      def inspect
        to_s
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
        nbr_lattices
        relevants
      ).each_with_index do |name, i|
        define_method(name) { props[i] }
      end
      public :atom_name, :lattice

      # The static (not arrayed) states of properties
      #   [atom_name, valence, lattice]
      #
      # @return [Array] the array of static states
      def static_states
        props[0..2]
      end

      # Has unfixed state or not
      # @return [Boolean] contain or not
      def unfixed?
        result = relevants.include?(Unfixed.property)
        raise 'Atom could not be unfixed!' if result && !unfixed_by_nbrs?
        result
      end

      # Checks that properties have unfixed state by neighbour lattices set
      # @return [Boolean] unfixed or not?
      def unfixed_by_nbrs?
        groups = nbr_lattices.group_by(&:first)
        atwrels = groups.find { |r, _| r == undirected_bond }
        atwrels && atwrels.last.map(&:last).compact.size == 1
      end

      # Checks that other properties contain all bonds from current properties
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def contain_all_bonds?(other)
        [:relations, :danglings, :nbr_lattices].all? do |name|
          contain_all_by?(other, name)
        end
      end

    private

      # Compares with other properties by some method which returns list
      # @param [AtomProperties] other the comparing properties
      # @param [Symbol] method by which will be comparing
      # @return [Boolean] lists are equal or not
      def eq_by?(other, method)
        lists_are_identical?(send(method), other.send(method), &:==)
      end

      %w(relations danglings nbr_lattices relevants).each do |name|
        # Compares current #{name} with other #{name}
        # @param [AtomProperties] other the comparing properties
        # @return [Boolean] lists are equal or not
        define_method(:"eq_#{name}?") do |other|
          eq_by?(other, name.to_sym)
        end

        # Checks that other properties contain all current #{name}
        # @param [AtomProperties] other the checking properties
        # @return [Boolean] contain or not
        method_name = :"contain_all_#{name}?"
        define_method(method_name) do |other|
          contain_all_by?(other, name.to_sym)
        end
      end

      # Checks that other properties contain all current states that go by some
      # method
      #
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def contain_all_by?(other, method)
        stats = send(method).dup
        other.send(method).all? { |rel| stats.delete_one(rel) }
      end

      # Compares basic values of two properties
      # @peram [AtomProperties] other the comparing properties
      # @return [Boolean] same or not
      def same_basic_values?(other)
        static_states == other.static_states
      end

      # Checks that current properties are not incoherent and if unfixed then
      # other is unfixed too
      #
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def same_correspond_relevants?(other)
        return false if relevant? && !other.relevant?
        return true unless relevant?
        !incoherent? && other.unfixed?
      end

      # Harvest relations of atom in spec
      # @param [DependentSpec | SpecResidual] spec see at #new same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   spec see at #new same argument
      # @return [Array] relations array
      def relations_for(spec, atom)
        remake_relations(spec, atom).map(&:last)
      end

      # Gets the relations of atom in spec, but drop positions and replace many
      # single undirected bonds to correspond values of :dbond as double bound and
      # :tbond as triple bond
      #
      # @param [DependentSpec | SpecResidual] spec see at #new same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   spec see at #new same argument
      # @return [Array] the array of pairs of atoms and replaced relations
      def remake_relations(spec, atom)
        return @_remake_result if @_remake_result

        # only bonds without relevat states and positions
        bonds = spec.relations_of(atom, with_atoms: true).select { |_, r| r.bond? }

        result = []
        until bonds.empty?
          atwrel = bonds.pop
          nbr, rel = atwrel
          if rel.belongs_to_crystal?
            result << atwrel
            next
          end

          same = bonds.select { |pair| pair == atwrel }
          new_relation =
            if same.empty?
              rel
            else
              bonds.delete_one(atwrel)
              if same.size == 3 && same.size != 4
                bonds.delete_one(atwrel)
                :tbond
              else
                :dbond
              end
            end

          result << [nbr, new_relation]
        end

        @_remake_result = result
      end

      # Harvest dangling bonds of atom in spec
      # @param [Minuend] spec see at #new same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   spec see at #new same argument
      # @return [Array] dangling states array
      def danglings_for(spec, atom)
        dang_rels = spec.relations_of(atom).reject(&:relation?)
        [Incoherent, Unfixed].map(&:property).reduce(dang_rels) do |acc, rel_prop|
          acc.delete(rel_prop)
          acc
        end
      end

      # Collects only lattices which are reacheble through each undirected bond
      # @param [Minuend] spec see at #new same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   spec see at #new same argument
      # @return [Array] the array of achieving lattices and correspond relations
      def nbr_lattices_for(spec, atom)
        relations_with_atoms = remake_relations(spec, atom)
        possible_vals = [undirected_bond, :dbond, :tbond]
        relations_with_atoms.reduce([]) do |acc, (atom, relation)|
          possible_vals.include?(relation) ? acc << [relation, atom.lattice] : acc
        end
      end

      # Checks that list of relevants is not include both values in same time
      # @param [Array] rels the array of relevant states
      # @return [Array] the original relevant states
      def check_relevants(rels)
        if rels.include?(Unfixed.property) && rels.include?(Incoherent.property)
          raise 'Unfixed atom already incoherent'
        end
        rels
      end

      # Drops relevants properties if it exists
      # @return [Array] properties without relevants
      def without_relevants
        wr = props.dup
        wr[-1] = [] if relevant?
        wr
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
        count_relations(Concepts::Bond) +
          (relations.include?(:dbond) ? 2 : 0) +
          (relations.include?(:tbond) ? 3 : 0)
      end

      # Gets number of established and dangling bond relations
      # @return [Integer] the total number of bonds
      def bonds_num
        estab_bonds_num + danglings.size
      end
    end

  end
end
