module VersatileDiamond
  module Concepts

    # Instance of it class represents usual specific spec that is most commonly
    # used in reactions
    class SpecificSpec
      include Modules::RelationBetweenChecker
      include BondsCounter
      extend Forwardable

      def_delegators :@spec, :extendable?, :gas?, :simple?
      attr_reader :spec, :specific_atoms

      # Initialize specific spec instalce. Checks specified atom for correct
      # valence value
      #
      # @param [Spec] spec the base spec instance
      # @param [Hash] specific_atoms references to specific atoms. Uses only for easy
      #   setup from rspec tests
      def initialize(spec, specific_atoms = {})
        spatoms = specific_atoms.map do |atom_keyname, specific_atom|
          atom = spec.atom(atom_keyname)
          unused_bonds = spec.external_bonds_for(atom) -
            specific_atom.actives - specific_atom.monovalents.size

          if unused_bonds < 0
            raise Atom::IncorrectValence.new(atom_keyname)
          end

          correct_atom =
            # references should have same incident relations
            if atom.reference? && !specific_atom.reference?
              SpecificAtom.new(atom, ancestor: specific_atom)
            else
              specific_atom
            end

          [atom_keyname, correct_atom]
        end

        @specific_atoms = Hash[spatoms]
        @spec = spec
        @original_name = spec.name

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

      # Updates base spec from which dependent current specific spec
      # @param [Spec] new_spec the new base spec
      def replace_base_spec(new_spec)
        rename_used_keynames_and_update_links(new_spec)
        @spec = new_spec
      end

      # Finds positions between atoms in base structure.
      # Can be used only for specified *surface* spec.
      #
      # @param [Atom] atom1 the first atom
      # @param [Atom] atom2 the second atom
      # @return [Position] nil or positions between atoms in both directions
      def position_between(atom1, atom2)
        spec.position_between(base_atom(atom1), base_atom(atom2))
      end

      # Builds the full name of specific spec (with specificied atom info)
      # @return [Symbol] the full name of specific spec
      def name
        sorted_atoms = @specific_atoms.to_a.sort { |(k1, _), (k2, _)| k1 <=> k2 }
        args = sorted_atoms.reduce([]) do |arr, (keyname, atom)|
          atom.actives.times { arr << "#{keyname}: *" }
          arr + relevants_for(atom) + monovalents_for(atom)
        end

        :"#{@original_name}(#{args.join(', ')})"
      end

      # Gets corresponding atom, because it can be specific atom
      # @param [Symbol] keyname the atom keyname
      # @return [Atom | SpecificAtom] the corresponding atom
      def atom(keyname)
        @specific_atoms[keyname] || spec.atom(keyname)
      end

      # Returns a keyname of passed atom
      # @param [Atom] atom the atom for which keyname will be found
      # @return [Symbol] the keyname of atom
      def keyname(atom)
        @specific_atoms.invert[atom] || spec.keyname(atom)
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
        unless atom.specific?
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
        @links ||= spec.links_with_replace_by(@specific_atoms)
      end

      %w(incoherent unfixed).each do |state|
        method_name = :"#{state}!"
        # Defines #{state} method which change a state of atom selected by
        # keyname
        #
        # @param [Symbol] atom_keyname the keyname of selecting atom
        # @raise [Errors::SyntaxError] if atom already has setuping state
        define_method(method_name) do |atom_keyname|
          atom = @specific_atoms[atom_keyname]
          unless atom
            atom = SpecificAtom.new(spec.atom(atom_keyname))
            @specific_atoms[atom_keyname] = atom
            reset_caches
          end
          atom.send(method_name)
        end
      end

      # Counts number of external bonds
      # @return [Integer] the number of external bonds
      def external_bonds
        # TODO: incorrect counting because material balance matcher depends from it
        # TODO: replace external bonds logic to directly using number of atoms
        spec.external_bonds - active_bonds_num #- monovalents_num
      end

      # Extends originial spec by atom-references and store it to temp variable
      # after that counts bonds for extended spec
      #
      # @return [Integer] the number of external bonds for extended spec
      def external_bonds_after_extend
        return @external_bonds_after_extend if @external_bonds_after_extend
        @extended_spec = spec.extend_by_references
        @external_bonds_after_extend = @extended_spec.external_bonds - active_bonds_num
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

        @specific_atoms.each do |keyname, atom|
          rd_atom = @correct_reduced.atom(keyname)
          is_specific = @correct_reduced.specific_atoms[keyname]
          df = atom.diff(rd_atom)

          if is_specific
            rd_atom.apply_diff(df)
          else
            @correct_reduced.
              describe_atom(keyname, SpecificAtom.new(rd_atom, ancestor: atom))
          end
        end
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
        self.class == other.class ? correspond?(other) : other.same?(self)
      end

      # Checks termination atom at the inner atom which belongs to current spec
      # @param [Atom | SpecificAtom] internal_atom the atom which belongs to
      #   current spec
      # @param [AtomicSpec] term_spec the termination specie with monovalent atom
      # @return [Boolean] has termination atom or not
      def has_termination?(internal_atom, term_spec)
        (term_spec.hydrogen? && external_bonds_for(internal_atom) > 0) ||
          internal_atom.monovalents.include?(term_spec)
      end

      # Counts the sum of active bonds
      # @return [Integer] sum of active bonds
      def active_bonds_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.actives }
      end

      # Counts the sum of monovalent atoms at specific atoms
      # @return [Integer] sum of monovalent atoms
      def monovalents_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.monovalents.size }
      end

      def to_s
        spec.to_s
      end

      def inspect
        name.to_s
      end

    protected

      attr_writer :reduced

    private

      # Gets analog atom from base spec
      # @param [Atom] atom from current or from base spec
      # @return [Atom] the atom from base spec
      def base_atom(atom)
        spec.atom(keyname(atom))
      end

      # Renames internal used keynames to new keynames from another base spec
      # @param [Spec] other the base spec from which keynames will gotten
      def rename_used_keynames_and_update_links(other)
        mirror = Mcs::SpeciesComparator.make_mirror(spec, other)

        new_specific_atoms = {}
        @specific_atoms.each do |old_keyname, atom|
          base_atom = spec.atom(old_keyname)
          other_atom = mirror[base_atom]
          new_keyname = other_atom ? other.keyname(other_atom) : old_keyname

          # raise could be when other base spec contain keynames same as residual
          # atom keynames which are present if other base spec atoms size less than
          # previous base spec atoms size
          raise 'Keyname is duplicated' if new_specific_atoms[new_keyname]
          new_specific_atoms[new_keyname] = atom
        end

        update_links(mirror)
        @specific_atoms = new_specific_atoms
      end

      # Updates current links to correct atoms from some other base spec
      # @param [Hash] mirror of atoms from prev base to some other new base spec
      def update_links(mirror)
        # before build curret links cache by calling #links method
        new_links = links.map do |atom_key, atoms_ref_list|
          new_atom_key = mirror[atom_key] || atom_key
          new_atoms_ref_list = atoms_ref_list.map do |a, r|
            [mirror[a] || a, r]
          end

          [new_atom_key, new_atoms_ref_list]
        end

        @links = Hash[new_links]
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

      # Verifies that the passed instance is correspond to the current, by
      # using the Hanser's algorithm
      #
      # @param [SpecificSpec] other see at #same? same argument
      # @return [Boolean] the result of Hanser's algorithm
      def correspond?(other)
        equal?(other) || (links.size == other.links.size &&
          Mcs::SpeciesComparator.contain?(self, other))
      end

      # Resets internal caches
      def reset_caches
        @links = nil
        @external_bonds_after_extend = nil
      end
    end

  end
end
