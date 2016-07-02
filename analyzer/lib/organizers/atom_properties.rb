module VersatileDiamond
  using Patches::RichArray
  using Patches::RichString

  module Organizers

    # Accumulates information about atom
    class AtomProperties
      include Modules::ListsComparer
      include Modules::OrderProvider
      include Lattices::BasicRelations

      extend Lattices::BasicRelations::Amorph
      UNDIRECTED_BONDS = [undirected_bond, double_bond, triple_bond].freeze
      INCOHERENT = Concepts::Incoherent.property.freeze
      UNFIXED = Concepts::Unfixed.property.freeze
      RELATIVE_PROPERTIES = [UNFIXED, INCOHERENT].freeze

      ACTIVE_BOND = Concepts::ActiveBond.property.freeze
      HYDROGEN = Concepts::AtomicSpec.new(Concepts::Atom.hydrogen).freeze

      UNIT_STATES = %i(atom_name valence).freeze
      STATIC_STATES = (UNIT_STATES + [:lattice]).freeze
      DYNAMIC_STATES = %i(relations danglings nbr_lattices relevants).freeze
      ALL_STATES = (STATIC_STATES + DYNAMIC_STATES).freeze

      class << self
        # Makes
        def raw(atom, **opts)
          atom_props = %i(name original_valence lattice)
          props = atom_props.map { |method_name| atom.public_send(method_name) } +
            DYNAMIC_STATES.map { |state| opts[state] || [] }

          new(props)
        end
      end

      # Fills under AtomClassifier#organize_properties
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
        if args.one?
          arg = args.first
          if arg.is_a?(Array)
            @props = arg
          elsif arg.is_a?(Hash)
            @props = [
              arg[:atom_name] || raise(ArgumentError, 'Undefined atom name'),
              arg[:valence] || raise(ArgumentError, 'Undefined valence'),
              arg[:lattice] || raise(ArgumentError, 'Undefined lattice'),
              arg[:relations] || raise(ArgumentError, 'Undefined relations'),
              arg[:danglings] || [],
              arg[:nbr_lattices] || [],
              arg[:relevants] ? check_and_dup_relevants_from(arg[:relevants]) : []
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
            check_and_dup_relevants_from(atom.relevants)
          ]
        else
          raise ArgumentError, 'Wrong number of arguments'
        end

        @smallests, @sames = nil

        @_is_incoherent, @_is_unfixed, @_is_unfixed_from_nbrs = nil
        @_estab_bond_num, @_actives_num, @_dangling_hydrogens_num = nil
        @_hash, @_to_s = nil
      end

      # Deep compares two properties by all properties
      # @param [AtomProperties] other an other atom properties
      # @return [Boolean] equal or not
      def ==(other)
        same_basic_values?(other) && DYNAMIC_STATES.all? { |stn| eq_by?(other, &stn) }
      end
      alias :eql? :==

      # Compares two atom properties
      # @param [AtomProperties] other comparing atom properties
      # @return [Integer] the comparing result
      def <=>(other)
        if include?(other)
          1
        elsif other.include?(self)
          -1
        else
          typed_order(self, other, :atom_name) do
            order(self, other, :valence) do
              typed_order(self, other, :lattice) do
                order(self, other, :estab_bonds_num) do
                  order(self, other, :crystal_relatons, :sort) do
                    order(self, other, :danglings, :sort, :reverse) do
                      order(self, other, :actives_num) do
                        typed_order(self, other, :unfixed?) do
                          typed_order(self, other, :incoherent?)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      # Gets new atom properties instance from two instances
      # @param [AtomProperties] other adding atom properties
      # @option [Integer] :limit the number of maximal nbr_lattcies
      # @return [AtomProperties] the extended instance of atom properties or nil
      def +(other, limit: nil)
        total_props = merge_props(other, &:+)
        return unless total_props
        return if limit && total_props[:nbr_lattices].size > limit

        lattices_num = total_props[:nbr_lattices].select(&:last).size
        total_unfixed = total_props[:relevants].include?(UNFIXED)
        return if total_unfixed && lattices_num > 1

        any_without_lattices = ![self, other].all?(&:lattice)
        return if total_unfixed && !any_without_lattices

        total_incoherent = total_props[:relevants].include?(INCOHERENT)
        any_without_bonds = [self, other].any? { |x| x.relations.empty? }
        return if total_incoherent && !any_without_bonds

        bonds_num = estab_bonds_num_in(total_props[:relations])
        dang_num = total_props[:danglings].size
        ext_num = bonds_num + dang_num

        is_incoherent = bonds_num < valence && total_incoherent
        is_unfixed = lattices_num == 1 && total_unfixed
        is_complete = (ext_num == valence)
        is_relevant = is_incoherent || is_unfixed
        is_unrelevanted = is_complete && is_relevant

        total_props[:lattice] = nil if lattices_num > 0
        if is_unrelevanted
          total_props[:relevants] = []
        elsif total_incoherent
          total_props[:relevants] = [INCOHERENT]
        end

        are_correct_props =
          (valid_relations?(total_props[:lattice], total_props[:relations])) &&
          (is_unrelevanted || ext_num < valence ||
            (is_complete && total_props[:relevants].empty?))

        are_correct_props ? self.class.new(state_values(total_props)) : nil
      end

      # Gets the difference between two atom properties
      # @param [AtomProperties] other atom properties which will be erased from current
      # @return [AtomProperties] the difference result or nil
      def -(other)
        diff_props = merge_props(other) do |self_state, other_state|
          other_state.all?(&self_state.public_method(:include?)) &&
            self_state.accurate_diff(other_state)
        end

        if diff_props && DYNAMIC_STATES.all? { |sn| diff_props[sn] }
          self.class.new(state_values(diff_props))
        else
          nil
        end
      end

      # Accurate combines two atom properties
      # @param [AtomProperties] other atom properties which will be accurate added
      # @return [AtomProperties] the sum or nil
      def safe_plus(other)
        both = [self, other]
        smallests_of_both = both.map { |props| props.smallests || Set[props] }
        max_root = smallests_of_both.reduce(:&).max
        return nil unless max_root

        diffs = both.map { |x| x - max_root }
        return nil unless diffs.all?

        is_zero_diffs = diffs.all?(&:zero?)
        right_diffs = is_zero_diffs ? both : diffs
        rests_sum = right_diffs.reduce(:+)
        return nil unless rests_sum

        is_zero_diffs ? rests_sum : max_root + rests_sum
      end

      # Calculates the hash of current instance for using it as key values in Hashes
      # @return [Integer] the hash of current instance
      def hash
        @_hash ||= ([atom_name, valence, lattice && lattice.instance] +
                          relations.sort + danglings.sort + relevants.sort +
                          nbr_lattices.map { |r, l| [r, l && l.instance] }.sort).hash
      end

      # Gets idempotent value of atom properties group
      # @return [AtomProperties] zero
      def zero
        self - self
      end

      # @return [Boolean]
      def zero?
        self == zero
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
        return false unless same_basic_values?(other)
        return false unless other.contain_all_relevants?(self)
        if incoherent? && other.relevant?
          other.eq_relevant_bonds?(self)
        else
          other.contain_all_bonds?(self)
        end
      end

      # Checks that some atom can have both properties: self and other
      # @param [AtomProperties] other checking atom properties
      # @return [Boolean] are self properties like other or not
      def like?(other)
        include?(other) || other.include?(self) || !!safe_plus(other)
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
        same_basic_values?(other) && (incoherent? || maximal?) &&
          (maximal? || !other.relevant?) && same_dynamics?(other)
      end

      # Checks that other properties have same unfixed state
      # @param [AtomProperties] other probably same properties by unfixed state
      # @return [Boolean] same or not
      def same_unfixed?(other)
        same_basic_values?(other) && (unfixed? || maximal?) &&
          (maximal? || !other.unfixed?) && other.unfixed_by_nbrs? &&
          same_dynamics?(other)
      end

      # Checks that current properties correspond to atom, lattice and have same
      # relations pack
      #
      # @param [Hash] info about checkable properties
      # @return [Boolean] is correspond or not
      def correspond?(info)
        info.all? do |key, value|
          internal_value = send(key)
          if internal_value.is_a?(Array)
            lists_are_identical?(internal_value, value)
          else
            internal_value == value
          end
        end
      end

      %w(smallest same).each do |name|
        plur_name = :"#{name}s"
        var_name = :"@#{plur_name}"

        # Adds dependency from #{name} atom properties
        # @param [AtomProperties] stuff the #{name} atom properties from which the
        #   current atom properties depends
        define_method(:"add_#{name}") do |stuff|
          var = instance_variable_get(var_name) ||
            instance_variable_set(var_name, Set.new)

          from_child = stuff.public_send(plur_name)
          var.subtract(from_child) if from_child
          var << stuff
        end
      end

      # Makes unrelevanted copy of self
      # @return [AtomProperties] unrelevanted atom properties
      def unrelevanted
        self.class.new(without_relevants)
      end

      # Has any relevant state or not
      # @return [Boolean]
      def relevant?
        incoherent? || unfixed?
      end

      # Has unfixed state or not
      # @return [Boolean] contain or not
      def unfixed?
        return @_is_unfixed unless @_is_unfixed.nil?
        @_is_unfixed = relevants.include?(UNFIXED)
      end

      # Has incoherent state or not
      # @return [Boolean] contain or not
      def incoherent?
        return @_is_incoherent unless @_is_incoherent.nil?
        @_is_incoherent = relevants.include?(INCOHERENT)
      end

      # Makes incoherent copy of self
      # @return [AtomProperties] incoherented atom properties or nil
      def incoherent
        if valence > bonds_num && !incoherent?
          props = without_relevants
          props[-1] = [INCOHERENT]
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
        add_dangling(ACTIVE_BOND)
      end

      # Gets property same as current but with added dangling property
      # @return [AtomProperties] extended properties or nil
      def add_dangling(dangling)
        if valence > bonds_num
          ext_dangs = danglings + [dangling]
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
        remove_dangling(ACTIVE_BOND)
      end

      # Gets property same as current but witout dangling property
      # @return [AtomProperties] reduced properties or nil
      def remove_dangling(dangling)
        dgs = danglings.dup
        if dgs.delete_one(dangling)
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
        @_actives_num ||= count_danglings(ACTIVE_BOND)
      end

      # Gets the number of actives when each established bond replaced to active bond
      # @return [Integer] number of unbonded actives
      def unbonded_actives_num
        estab_bonds_num + actives_num
      end

      # Gets number of hydrogen atoms
      # @return [Integer] number of active bonds
      def dangling_hydrogens_num
        @_dangling_hydrogens_num ||= count_danglings(HYDROGEN)
      end

      # Counts total number of hydrogen atoms
      # @return [Integer] the number of total number of hydrogen atoms
      def total_hydrogens_num
        valence - bonds_num + dangling_hydrogens_num
      end

      # Gets the number of neighbour lattices of current atom properties
      # @return [Integer]
      def nbr_lattices_num
        nbr_lattices.size
      end

      # Checks has or not free bonds?
      # @return [Boolean] can form additional bond or not
      def has_free_bonds?
        return false if incoherent?
        num = unbonded_actives_num + dangling_hydrogens_num
        raise 'Wrong valence' if num > valence
        num < valence
      end

      # Convert properties to string representation
      # @return [String] the string representaion of properties
      def to_s
        return @_to_s if @_to_s

        name = atom_name.to_s

        dg = danglings.dup
        name = "*#{name}" while dg.delete_one(ACTIVE_BOND)

        while (monovalent_atom = dg.pop)
          name = "#{monovalent_atom}#{name}"
        end

        if relevant?
          relevants.each do |suffix|
            name = "#{name}:#{suffix}"
          end
        end

        name = "#{name}%#{lattice.name}" if lattice

        all_nls_groups = nbr_lattices.groups(&:last)
        many_nls_groups = all_nls_groups.reject(&:one?)
        mono_nls_groups = all_nls_groups.select(&:one?).reduce(:+)
        lattice_symbol = -> rel do
          if rel.multi?
            g = many_nls_groups.find { |g| g.size == rel.arity }
            frl = g && g.pop
            frl && (rel.arity - 1).times(&g.public_method(:pop))
          else
            olc = mono_nls_groups && mono_nls_groups.pop
            mlc = many_nls_groups.reject(&:empty?).first
            frl = olc || (mlc && mlc.pop)
          end
          (frl && frl.last) || '_'
        end

        rl = relations.dup
        down1 = rl.delete_one(bond_cross_110)
        down2 = rl.delete_one(bond_cross_110)
        if down1 && down2
          name = "#{name}<"
        elsif down1 || down2
          name = "#{name}/"
        elsif rl.delete_one(triple_bond)
          name = "#{name}≡#{lattice_symbol[triple_bond]}"
        elsif rl.delete_one(double_bond)
          name = "#{name}=#{lattice_symbol[double_bond]}"
        elsif rl.delete_one(undirected_bond)
          name = "#{name}~#{lattice_symbol[undirected_bond]}"
        end

        up1 = rl.delete_one(bond_front_110)
        up2 = rl.delete_one(bond_front_110)
        if up1 && up2
          name = ">#{name}"
        elsif up1 || up2
          name = "^#{name}"
        elsif rl.delete_one(double_bond)
          name = "#{lattice_symbol[double_bond]}=#{name}"
        end

        name = "-#{name}" if rl.delete_one(bond_front_100)
        name = "#{name}-" if rl.delete_one(bond_front_100)
        while rl.delete_one(undirected_bond)
          name = "#{lattice_symbol[undirected_bond]}~#{name}"
        end

        @_to_s = name
      end

      def inspect
        to_s
      end

    protected

      attr_reader :props

      # Define human named methods for accessing to props
      ALL_STATES.each_with_index do |name, i|
        define_method(name) { props[i] }
      end
      public :atom_name, :lattice, :relations, :danglings, :nbr_lattices, :relevants

      # The static (not arrayed) states of properties
      # @return [Array] the array of static states
      def static_states
        STATIC_STATES.map(&method(:send))
      end

      # Checks that properties have unfixed state by neighbour lattices set
      # @return [Boolean] unfixed or not?
      def unfixed_by_nbrs?
        return @_is_unfixed_from_nbrs unless @_is_unfixed_from_nbrs.nil?
        nbub = nbr_lattices.select { |r, _| r == undirected_bond }
        @_is_unfixed_from_nbrs =
          nbub.reduce(0) { |acc, (_, l)| acc + (l ? 1 : 0) } == 1
      end

      # Checks that other properties contain all bonds from current properties
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] contain or not
      def contain_all_bonds?(other)
        [:relations, :danglings, :nbr_lattices].all? do |name|
          contain_all_by?(other, &name)
        end
      end

      # Checks that other properties have equal relations and neighbour lattices but
      #   contains all dangling properties
      # @param [AtomProperties] other the checking properties
      # @return [Boolean] equal or not
      def eq_relevant_bonds?(other)
        eq_relations?(other) && eq_nbr_lattices?(other) &&
          contain_all_danglings?(other)
      end

    private

      # Transforms passed hash to flatten sequence of states
      # @param [Hash] props_hash
      # @return [Array] the array of states
      def state_values(props_hash)
        ALL_STATES.map { |state| props_hash[state] }
      end

      # Makes merged props hash with other instance by passed operation
      # @param [AtomProperties] other provider of properties
      # @yield binary operation which applies the dynamic states of both instances
      # @return [Array] the list of the merged properties hash
      def produce_props(other, &block)
        unit_props = UNIT_STATES.zip([atom_name, valence]).to_h
        all_lattices = [self, other].map(&:lattice).uniq
        any_unfixed = [self, other].any?(&:unfixed?)
        iterating_lattices =
          all_lattices == [nil] || any_unfixed ? [nil] : all_lattices.select(&:itself)

        iterating_lattices.each_with_object(unit_props) do |lts, result|
          result[:lattice] = lts
          DYNAMIC_STATES.each do |state_name|
            self_state, other_state = [self, other].map { |x| x.send(state_name) }
            result[state_name] = block[self_state, other_state]
          end

          unless result[:relevants]
            if relevants.include?(UNFIXED) && other.relevants.include?(INCOHERENT)
              result[:relevants] = [UNFIXED]
            end
          end
        end
      end

      # Merges own properties with properties of an other passed instance
      # @param [AtomProperties] other provider of properties
      # @yield binary operation which applies the dynamic states of both instances
      # @return [Hash] the merged properties hash or nil if properties cannot be merged
      def merge_props(other, &block)
        same_unit_states = UNIT_STATES.all? { |mn| send(mn) == other.send(mn) }
        is_valid_lts = lattice == other.lattice ||
                  (!lattice && other.lattice) || (lattice && !other.lattice)

        if same_unit_states && is_valid_lts
          mps = produce_props(other, &block)
          mps[:relevants] = mps[:relevants] ? mps[:relevants].uniq : []
          lattices_num = mps[:nbr_lattices] ? mps[:nbr_lattices].size : 0
          undir_bonds_num = mps[:relations] ? undir_bonds_num_in(mps[:relations]) : 0
          (undir_bonds_num == lattices_num ||
            (mps[:relations] && mps[:relations].any?(&:multi?))) &&
              mps
        else
          nil
        end
      end

      # Compares dynamic states of two properties
      # @peram [AtomProperties] other the comparing properties
      # @return [Boolean] equal or not
      def same_dynamics?(other)
        eq_nbr_lattices?(other) && eq_relations?(other) && same_danglings?(other)
      end

      # Compares with other properties by some method which returns list
      # @param [AtomProperties] other the comparing properties
      # @yield method by which will be comparing
      # @return [Boolean] lists are equal or not
      def eq_by?(other, &block)
        lists_are_identical?(block[self], block[other])
      end

      DYNAMIC_STATES.each do |method_name|
        # Compares current #{method_name} with other #{method_name}
        # @param [AtomProperties] other the comparing properties
        # @return [Boolean] lists are equal or not
        define_method(:"eq_#{method_name}?") do |other|
          eq_by?(other, &method_name)
        end

        # Checks that other properties contain all current #{method_name}
        # @param [AtomProperties] other the checking properties
        # @return [Boolean] contain or not
        define_method(:"contain_all_#{method_name}?") do |other|
          contain_all_by?(other, &method_name)
        end
      end
      protected :contain_all_relevants?

      # Checks that other properties contain all current states that go by some
      # method
      #
      # @param [AtomProperties] other the checking properties
      # @yield method by which will be comparing
      # @return [Boolean] contain or not
      def contain_all_by?(other, &block)
        stats = block[self].dup
        block[other].all? { |rel| stats.delete_one(rel) }
      end

      # Compares dynamic states of two properties
      # @peram [AtomProperties] other the comparing properties
      # @return [Boolean] equal or not
      def same_dynamics?(other)
        eq_nbr_lattices?(other) && eq_relations?(other) && same_danglings?(other)
      end

      # Compares dangling states of two properties
      # @peram [AtomProperties] other the comparing properties
      # @return [Boolean] similar danglings or not
      def same_danglings?(other)
        maximal? ? contain_all_danglings?(other) : eq_danglings?(other)
      end

      # Compares basic values of two properties
      # @peram [AtomProperties] other the comparing properties
      # @return [Boolean] same or not
      def same_basic_values?(other)
        static_states == other.static_states
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
      # single undirected bonds to correspond values of multi bounds
      #
      # @param [DependentSpec | SpecResidual] spec see at #new same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   spec see at #new same argument
      # @return [Array] the array of pairs of atoms and replaced relations
      def remake_relations(spec, atom)
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
                triple_bond
              else
                double_bond
              end
            end

          result << [nbr, new_relation]
        end

        result
      end

      # Harvest dangling bonds of atom in spec
      # @param [MinuendSpec] spec see at #new same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   spec see at #new same argument
      # @return [Array] dangling states array
      def danglings_for(spec, atom)
        dang_rels = spec.relations_of(atom).reject(&:relation?)
        RELATIVE_PROPERTIES.each_with_object(dang_rels) do |rel_prop, acc|
          acc.delete(rel_prop)
        end
      end

      # Collects only lattices which are reacheble through each undirected bond
      # @param [MinuendSpec] spec see at #new same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   spec see at #new same argument
      # @return [Array] the array of achieving lattices and correspond relations
      def nbr_lattices_for(spec, atom)
        remake_relations(spec, atom).reduce([]) do |acc, (atom, relation)|
          if UNDIRECTED_BONDS.include?(relation)
            acc + [[undirected_bond, atom.lattice]] * relation.arity
          else
            acc
          end
        end
      end

      # Collects and checks that relevant states are correct
      def check_and_dup_relevants_from(incoming_relevant_states)
        if incoming_relevant_states.size < 2 # just incoherent or unfixed
          incoming_relevant_states.dup
        else
          msg = "Incorrect pack of relevant states: #{incoming_relevant_states}"
          raise ArgumentError, msg
        end
      end

      # Checks that numbers of passed relations is correct
      # @param [Concepts::Lattice] lts
      # @param [Array] rels the array of relation states
      # @return [Boolean] is valid or not
      def valid_relations?(lts, rels)
        if lts
          limits = lts.instance.relations_limit
          rels.group_by(&:params).all? { |pr, rs| limits[pr] >= rs.size }
        else
          rels.all?(&UNDIRECTED_BONDS.public_method(:include?))
        end
      end

      # Drops relevants properties if it exists
      # @return [Array] properties without relevants
      def without_relevants
        wr = props.dup
        wr[-1] = [] if relevant?
        wr
      end

      # Gets number of undirected bonds
      # @param [Array] relations where bonds will be counted
      # @return [Integer] the number of undirected bond relations
      def undir_bonds_num_in(relations)
        UNDIRECTED_BONDS.map { |bond| relations.count(bond) * bond.arity }.reduce(:+)
      end

      # Gets number of established bond relations
      # @param [Array] relations where bonds will be counted
      # @return [Integer] the number of established bond relations
      def estab_bonds_num_in(relations)
        bonds = relations.select(&:bond?)
        bonds.reject(&:multi?).size +
          2 * bonds.count(double_bond) +
          3 * bonds.count(triple_bond)
      end

      # Gets number of established bond relations
      # @return [Integer] the number of established bond relations
      def estab_bonds_num
        @_estab_bond_num ||= estab_bonds_num_in(relations)
      end

      # Gets list of relations which belongs to crystal
      # @return [Array] the list of crystal relations
      def crystal_relatons
        relations.select(&:belongs_to_crystal?)
      end

      # Gets number of established and dangling bond relations
      # @return [Integer] the total number of bonds
      def bonds_num
        estab_bonds_num + danglings.size
      end

      # @return [Boolean] are all valence atoms has special state?
      def maximal?
        valence == bonds_num
      end
    end

  end
end
