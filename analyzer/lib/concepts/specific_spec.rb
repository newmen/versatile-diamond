module VersatileDiamond
  module Concepts

    # Instance of it class represents usual specific spec that is most commonly
    # used in reactions
    class SpecificSpec
      extend Forwardable

      include Visitors::Visitable
      include BondsCounter

      attr_reader :spec, :specific_atoms

      # Initialize specific spec instalce. Checks specified atom for correct
      # valence value
      #
      # @param [Spec] spec the base spec instance
      # @param [Hash] specific_atoms references to specific atoms
      def initialize(spec, specific_atoms = {})
        specific_atoms.each do |atom_keyname, specific_atom|
          atom = spec.atom(atom_keyname)
          unused_bonds = spec.external_bonds_for(atom) -
            specific_atom.actives - specific_atom.monovalents.size

          if unused_bonds < 0
            raise Atom::IncorrectValence.new(atom_keyname)
          end
        end

        @spec = spec
        @original_name = @spec.name
        @specific_atoms = specific_atoms

        @external_bonds_after_extend = nil
        @reduced, @correct_reduced = nil
      end

      # Makes a copy of other specific spec by dup each specific atom from it
      # @param [SpecificSpec] other the duplicating spec
      def initialize_copy(other)
        @spec = other.spec
        @specific_atoms = Hash[other.specific_atoms.map { |k, a| [k, a.dup] }]
        reset_caches
      end

      def_delegators :@spec, :extendable?, :gas?, :simple?

      # Updates base spec from which dependent current specific spec
      # @param [Spec] new_spec the new base spec
      def update_base_spec(new_spec)
        @spec = new_spec
      end

      # Finds positions between atoms in base structure.
      # Can be used only for specified *surface* spec.
      #
      # @param [Atom] atom1 the first atom
      # @param [Atom] atom2 the second atom
      # @return [Position] nil or positions between atoms in both directions
      def position_between(atom1, atom2)
        @spec.position_between(
          @spec.atom(keyname(atom1)), @spec.atom(keyname(atom2)))
      end

      # Gets original name of base spec
      # @return [Symbol] the original name of base spec
      def name
        @original_name
      end

      # Builds the full name of specific spec (with specificied atom info)
      # @return [String] the full name of specific spec
      def full_name
        sorted_atoms = @specific_atoms.to_a.sort do |(k1, _), (k2, _)|
          k1 <=> k2
        end

        args = sorted_atoms.reduce([]) do |arr, (keyname, atom)|
          arr << "#{keyname}: #{'*' * atom.actives}" if atom.actives > 0
          arr + relevants_for(atom) + monovalents_for(atom)
        end
        "#{name}(#{args.join(', ')})"
      end

      # Gets corresponding atom, because it can be specific atom
      # @param [Symbol] keyname the atom keyname
      # @return [Atom | SpecificAtom] the corresponding atom
      def atom(keyname)
        @specific_atoms[keyname] || @spec.atom(keyname)
      end

      # Returns a keyname of passed atom
      # @param [Atom] atom the atom for which keyname will be found
      # @return [Symbol] the keyname of atom
      def keyname(atom)
        @specific_atoms.invert[atom] || @spec.keyname(atom)
      end

      # Describes atom by storing it to specific atoms hash
      # @param [Symbol] keyname the keyname of new specified atom
      # @param [SpecificAtom] atom the specified atom which will be stored
      # @raise [ArgumentError] when keyname is undefined, or keyname already
      #   specified, or atom is not specified
      def describe_atom(keyname, atom)
        unless spec.atom(keyname)
          raise ArgumentError, "Undefined atom #{keyname} for #{name}!"
        end
        if @specific_atoms[keyname]
          raise ArgumentError,
            "Atom #{keyname} for specific #{name} already described!"
        end
        unless atom.is_a?(SpecificAtom)
          raise ArgumentError,
            "Described atom #{keyname} for specific #{name} cannot be unspecified"
        end
        @specific_atoms[keyname] = atom
        reset_caches
      end

      # Returns original links of base spec but exchange correspond atoms to
      # specific atoms
      #
      # @return [Hash] cached hash of all links between atoms
      def links
        @links ||= @spec.links_with_replace_by(@specific_atoms)
      end

      %w(incoherent unfixed).each do |state|
        # Defines #{state} method which change a state of atom selected by
        # keyname
        #
        # @param [Symbol] atom_keyname the keyname of selecting atom
        # @raise [Errors::SyntaxError] if atom already has setuping state
        define_method("#{state}!") do |atom_keyname|
          atom = @specific_atoms[atom_keyname]
          unless atom
            atom = SpecificAtom.new(@spec.atom(atom_keyname))
            @specific_atoms[atom_keyname] = atom
            reset_caches
          end
          atom.send("#{state}!")
        end
      end

      # Counts number of external bonds
      # @return [Integer] the number of external bonds
      def external_bonds
        @spec.external_bonds - active_bonds_num #- monovalents_num
      end

      # Extends originial spec by atom-references and store it to temp variable
      # after that counts bonds for extended spec
      #
      # @return [Integer] the number of external bonds for extended spec
      def external_bonds_after_extend
        return @external_bonds_after_extend if @external_bonds_after_extend
        @extended_spec = @spec.extend_by_references
        @external_bonds_after_extend =
          @extended_spec.external_bonds - active_bonds_num
      end

      # Makes a new specific spec by extended base spec
      # @return [SpecificSpec] the extended spec
      def extended
        external_bonds_after_extend unless @extended_spec

        spec = self.class.new(@extended_spec)
        spec.reduced = self
        @specific_atoms.each do |keyname, old_atom|
          spec.specific_atoms[keyname] =
            SpecificAtom.new(@extended_spec.atom(keyname), ancestor: old_atom)
        end
        spec
      end

      # Is extended or not
      # @return [Boolean] extended or not
      def extended?
        !!@reduced
      end

      # Makes a correct reduced spec by applying specific atoms from current
      # spec to reduced spec
      #
      # @return [SpecificSpec] correct reduced spec or nil
      def reduced
        return unless extended?

        return @correct_reduced if @correct_reduced
        @correct_reduced = @reduced.dup
        correct_is_same = true

        @specific_atoms.each do |keyname, atom|
          rd_atom = @correct_reduced.atom(keyname)
          is_specific = @correct_reduced.specific_atoms[keyname]
          df = atom.diff(rd_atom)

          correct_is_same = false unless is_specific && df.empty?

          if is_specific
            rd_atom.apply_diff(df)
          else
            @correct_reduced.
              describe_atom(keyname, SpecificAtom.new(rd_atom, ancestor: atom))
          end
        end
        @correct_reduced = @reduced if correct_is_same
        @correct_reduced
      end

      # Checks that specific spec could be reduced
      # @return [Boolean] could or not
      def could_be_reduced?
        extended? && Spec.good_for_reduce?(@specific_atoms.keys)
      end

      # Compares two specific specs
      # @param [TerminationSpec | SpecificSpec] other with which comparison
      # @return [Boolean] the same or not
      def same?(other)
        self.class == other.class && @spec == other.spec && correspond?(other)
      end

      # Checks termination atom at the inner atom which belongs to current spec
      # @param [Atom | SpecificAtom] internal_atom the atom which belongs to
      #   current spec
      # @param [Atom] term_atom the termination atom
      # @return [Boolean] has termination atom or not
      def has_termination_atom?(internal_atom, term_atom)
        (Atom.hydrogen?(term_atom) &&
          external_bonds_for(internal_atom) > 0) ||
          has_monovalent_in_links?(internal_atom, term_atom) ||
          (internal_atom.monovalents.include?(term_atom.name))
      end

      # Gets a number of atoms with number of active bonds, but if spec is gas
      # then their size just 0
      #
      # @return [Float] size of current specific spec
      def size
        gas? ?
          0 : @spec.size + (@specific_atoms.values.map(&:size).reduce(:+) || 0)
      end

      # Counts the sum of active bonds
      # @return [Integer] sum of active bonds
      def active_bonds_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.actives }
      end

      # Also visit base spec
      # @param [Visitors::Visitor] visitor the object which accumulate state of
      #   current instance
      # @override
      def visit(visitor)
        super
        @spec.visit(visitor)
      end

      def to_s
        # @spec.to_s(@spec.atoms.merge(@specific_atoms), links)
        @spec.to_s
      end

      def inspect
        full_name
      end

    protected

      attr_writer :reduced

    private

      # Selects bonds for passed atom
      # @param [Atom] atom the atom for which bonds will be selected
      # @return [Array] the array of bonds incedent to an atom
      # @override
      def internal_bonds_for(atom)
        valid_atom = links[atom] ? atom : atom(@spec.keyname(atom))
        super(valid_atom)
      end

      # Collect all relevant states for passed atom
      # @param [SpecificAtom] atom see at #collect_states same argument
      # @return [Array] the array of relevant states
      def relevants_for(atom)
        collect_states(atom, :relevants, 'to_s[0]')
      end

      # Collect all monovalent atoms for passed atom
      # @param [SpecificAtom] atom see at #collect_states same argument
      # @return [Array] the array of monovalent atoms
      def monovalents_for(atom)
        collect_states(atom, :monovalents)
      end

      # Collects all states of atom by passed for each of them
      # @param [SpecificAtom] atom the atom for which states will be got
      # @param [Symbol] atom_method the method states to take
      # @param [String] state_method the additional method that applied to each
      #   state if has
      # @return [Array] the array where each element is key-value string with
      #   atom keyname and some state
      def collect_states(atom, atom_method, state_method = nil)
        atom_keyname = keyname(atom)
        states = atom.send(atom_method)
        states.empty? ?
          [] :
          states.map do |state|
            state_str = state_method ? eval("state.#{state_method}") : state
            "#{atom_keyname}: #{state_str}"
          end
      end

      # Finds monovalent termination atom in links of spec
      # @param [Atom | SpecificAtom | AtomReference] internal_atom the atom for
      #   which will check that it have monovalent atom
      # @param [Atom] term_atom the monovalent atom which will be found or not
      # @return [Boolean] has or not
      def has_monovalent_in_links?(internal_atom, term_atom)
        !!links[internal_atom].find do |spec_atom, link|
          link.class == Bond && spec_atom.same?(term_atom)
        end
      end

      # Verifies that the passed instance is correspond to the current, by
      # using the Hanser's algorithm
      #
      # @param [SpecificSpec] other see at #same? same argument
      # @return [Boolean] the result of Hanser's algorithm
      def correspond?(other)
        HanserRecursiveAlgorithm.contain?(links, other.links)
      end

      # Resets internal caches
      def reset_caches
        @links = nil
        @external_bonds_after_extend = nil
      end
    end

  end
end
