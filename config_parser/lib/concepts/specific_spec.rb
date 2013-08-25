module VersatileDiamond
  module Concepts

    # Instance of it class represents usual specific spec that is most commonly
    # used in reactions
    class SpecificSpec
      extend Forwardable
      include BondsCounter

      attr_reader :spec

      # Initialize specific spec instalce. Checks specified atom for correct
      # valence value
      #
      # @param [Spec] spec the base spec instance
      # @param [Hash] specific_atoms references to specific atoms
      def initialize(spec, specific_atoms = {})
        specific_atoms.each do |atom_keyname, specific_atom|
          atom = spec.atom(atom_keyname)
          if spec.external_bonds_for(atom) - specific_atom.actives < 0
            raise Atom::IncorrectValence.new(atom_keyname)
          end
        end

        @spec = spec
        @specific_atoms = specific_atoms
        # @original_name = spec.name
      end

      # Makes a copy of other specific spec by dup each specific atom from it
      # @param [SpecificSpec] other the duplicating spec
      def initialize_copy(other)
        @spec = other.spec
        @specific_atoms = Hash[other.specific_atoms.map { |k, a| [k, a.dup] }]
        @links = nil
      end

      def_delegators :@spec, :name, :extendable?, :is_gas?, :simple?

      # Builds the full name of specific spec (with specificied atom info)
      # @return [String] the full name of specific spec
      def full_name
        args = @specific_atoms.reduce([]) do |arr, (keyname, atom)|
          arr << "#{keyname}: #{'*' * atom.actives}" if atom.actives > 0
          unless atom.relevants.empty?
            arr += atom.relevants.map do |state|
              "#{keyname}: #{state.to_s[0]}"
            end
          end
          arr
        end
        args = args.empty? ? '' : "(#{args.join(', ')})"
        "#{name}#{args}"
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
          end
          atom.send("#{state}!")
        end
      end

      # Counts number of external bonds
      # @return [Integer] the number of external bonds
      def external_bonds
        @spec.external_bonds - active_bonds_num
      end

      # Extends originial spec by atom-references and store it to temp variable
      # after that count bonds for extended spec
      #
      # @return [Integer] the number of external bonds for extended spec
      def external_bonds_after_extend
        return @external_bonds_after_extend if @external_bonds_after_extend
        @extended_spec = @spec.extend_by_references
        @external_bonds_after_extend =
          @extended_spec.external_bonds - active_bonds_num
      end

      # Exchange current base spec to extended base spec
      def extend!
        external_bonds_after_extend unless @extended_spec
        @external_bonds_after_extend = nil
        @links = nil
        @spec = @extended_spec
      end

      # Selects atoms that have changed compared to the other similar spec
      # @param [SpecificSpec] other another spec which similar as it
      # @return [Array] the array of changed atoms
      def changed_atoms(other_similar)
        actives, other_actives = only_actives, other_similar.only_actives

        atoms = actives.each_with_object([]) do |(keyname, atom), acc|
          other_atom = other_actives.delete(keyname)
          if !other_atom || atom.actives != other_atom.actives
            acc << atom
          end
        end

        atoms + other_actives.map { |keyname, _| @spec.atom(keyname) }
      end

      # Looks around by atom mapping result and changes incoherent or unfixed
      # property of internal atom if need
      #
      # @param [Array] atom_map the atom mapping result from reaction
      def look_around!(atom_map)
        return if is_gas?

        # TODO: need to check unfixing (??)

        atom_map.each do |specs, corrs|
          next unless specs.any? { |spec| spec == self }

          source, _ = specs
          xs = self == source ? [0, 1] : [1, 0]
          corrs.each do |mirror|
            atoms_with_links = specs.zip(mirror).map do |specific_spec, atom|
              [specific_spec, atom, specific_spec.internal_bonds_for(atom)]
            end

            _, own, incedent_bonds = atoms_with_links[xs.first]
            other, foreign, _ = atoms_with_links[xs.last]

            unless own.is_a?(SpecificAtom)
              keyname = @spec.keyname(own) # uses if differences exists
              own = SpecificAtom.new(own)
            end
            diff = own.diff(foreign)

            # TODO: if atom has not remain bonds then not set incoherent status (rspec it!)
            own.incoherent! if !own.incoherent? && (other.is_gas? ||
              (diff.include?(:incoherent) && own.valence > incedent_bonds))

            own.unfixed! if !own.unfixed? && incedent_bonds == 1 &&
              (other.is_gas? || (diff.include?(:unfixed) && !own.lattice))

            # store own specific atom if atom was a simple atom
            if keyname && (own.actives > 0 || !own.relevants.empty?)
              @specific_atoms[keyname] = own
              @links = nil
            end
          end
        end
      end

      # Gets parent specific spec
      # @return [SpecificSpec] the parten specific spec or nil
      def parent
        @parent
      end

      # Organize dependencies from another similar species. Dependencies set if
      # similar spec has less specific atoms and existed specific atoms is same
      # in both specs. Moreover, activated atoms have a greater advantage.
      #
      # @param [Array] similar_specs the array of specs where each spec has
      #   same basic spec
      def organize_dependencies!(similar_specs)
        similar_specs = similar_specs.reject do |s|
          s == self || s.specific_atoms.size > @specific_atoms.size
        end
        similar_specs = similar_specs.sort do |a, b|
          if a.specific_atoms.size == b.specific_atoms.size
            b.active_bonds_num <=> a.active_bonds_num
          else
            b.specific_atoms.size <=> a.specific_atoms.size
          end
        end

        @parent = similar_specs.find do |ss|
          ss.active_bonds_num <= active_bonds_num &&
            ss.specific_atoms.all? do |keyname, atom|
              a = @specific_atoms[keyname]
              a && atom.actives <= a.actives &&
                (atom.relevants - a.relevants).empty?
            end
        end
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
        (Atom.is_hydrogen?(term_atom) &&
          external_bonds_for(internal_atom) > 0) ||
            links[internal_atom].find do |spec_atom, link|
              link.class == Bond && spec_atom.same?(term_atom)
            end
      end

  #     def visit(visitor)
  #       @spec.visit(visitor)
  #       visitor.accept_specific_spec(self)
  #     end

      def to_s
        # @spec.to_s(@spec.atoms.merge(@specific_atoms), links)
        @spec.to_s
      end

      def inspect
        full_name
      end

    protected

      attr_reader :specific_atoms

      # Selects only active atoms
      # @return [Hash] the hash where active atoms presents as values
      def only_actives
        @specific_atoms.select { |_, atom| atom.actives > 0 }
      end

      # Counts the sum of active bonds
      # @return [Integer] sum of active bonds
      def active_bonds_num
        only_actives.reduce(0) { |acc, (_, atom)| acc + atom.actives }
      end

      # Selects bonds for passed atom
      # @param [Atom] atom the atom for which bonds will be selected
      # @return [Array] the array of bonds incedent to an atom
      # @override
      def internal_bonds_for(atom)
        valid_atom = links[atom] ? atom : atom(@spec.keyname(atom))
        super(atom)
      end

      # Returns original links of base spec but exchange correspond atoms to
      # specific atoms
      #
      # @return [Hash] cached hash of all links between atoms
      def links
        @links ||= @spec.links_with_replace_by(@specific_atoms)
      end

    private

      # Verifies that the passed instance is correspond to the current, by
      # using the Hanser's algorithm
      #
      # @param [SpecificSpec] other see at #same? same argument
      # @return [Boolean] the result of Hanser's algorithm
      def correspond?(other)
        HanserRecursiveAlgorithm.contain?(links, other.links)
      end
    end

  end
end
