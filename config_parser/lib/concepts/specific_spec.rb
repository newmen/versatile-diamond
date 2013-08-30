module VersatileDiamond
  module Concepts

    # Instance of it class represents usual specific spec that is most commonly
    # used in reactions
    class SpecificSpec
      extend Forwardable

      include Visitors::Visitable
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
        reset_caches
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
        args = "(#{args.join(', ')})"
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

      # Describes atom by storing it to specific atoms hash
      # @param [Symbol] keyname the keyname of new specified atom
      # @param [SpecificAtom] atom the specified atom which will be stored
      # @raise [ArgumentError] when keyname is undefined, or keyname already
      #   specified, or atom is not specified
      def describe_atom(keyname, atom)
        if !spec.atom(keyname)
          raise ArgumentError, "Undefined atom #{keyname} for #{name}!"
        end
        if @specific_atoms[keyname]
          raise ArgumentError,
            "Atom #{keyname} for specific #{name} already described!"
        end
        if !atom.is_a?(SpecificAtom)
          raise ArgumentError,
            "Described atom #{keyname} for specific #{name} cannot be"
            "unspecified"
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

      # Makes a new specific spec by extended base spec
      # @return [SpecificSpec] the extended spec
      def extended
        external_bonds_after_extend unless @extended_spec

        spec = self.class.new(@extended_spec)
        @specific_atoms.each do |keyname, old_atom|
          spec.specific_atoms[keyname] =
            SpecificAtom.new(@extended_spec.atom(keyname), ancestor: old_atom)
        end
        spec
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

      # Gets a number of atoms with number of active bonds, but if spec is gas
      # then their size just 0
      #
      # @return [Float] size of current specific spec
      def size
        is_gas? ? 0 : @spec.size + active_bonds_num + relevants_num * 0.34
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

      attr_reader :specific_atoms

      # Counts the sum of active bonds
      # @return [Integer] sum of active bonds
      def active_bonds_num
        @specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.actives }
      end

      # Counts the sum of relevant properties of specific atoms
      # @return [Integer] sum of relevant properties
      def relevants_num
        relevants = @specific_atoms.values.reduce([]) do |acc, atom|
          acc + atom.relevants
        end
        relevants.size
      end

      # Selects bonds for passed atom
      # @param [Atom] atom the atom for which bonds will be selected
      # @return [Array] the array of bonds incedent to an atom
      # @override
      def internal_bonds_for(atom)
        valid_atom = links[atom] ? atom : atom(@spec.keyname(atom))
        super(atom)
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

      # Resets internal caches
      def reset_caches
        @links = nil
        @external_bonds_after_extend = nil
      end
    end

  end
end
