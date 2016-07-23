module VersatileDiamond
  module Concepts

    # The class instance contains atoms and bonds between them.
    # @abstract
    class Spec < Named
      include Modules::RelationBetweenChecker
      include AtomsSwapper
      include BondsCounter
      include Linker

      attr_reader :atoms # must be protected!! only for SpecificSpec#to_s
      attr_reader :links

      class << self
        # Checks that all atom keynames suitable for reducing
        # @param [Array] keynames the array of atom keyname which will be checked
        # @return [Boolean] all situable or not
        def good_for_reduce?(keynames)
          !keynames.any?(&method(:extended?))
        end

        # Checks that atom keyname has been used for extending
        # @param [Symbol] keyname
        # @return [Boolean] is keyname suitable for reducing
        def extended?(keyname)
          !!(keyname =~ /_$/)
        end
      end

      # Creates [Symbol]Atom as atoms and [Atom][[Atom, Bond]] as links
      # @param [Symbol] name the name of spec
      # @param [Hash] atoms the associated array [Symbol]Atom
      def initialize(name, **atoms)
        super(name)
        @atoms, @links = {}, {}
        atoms.each { |k, a| describe_atom(k, a) }

        @is_extended = false

        @_keynames_to_atoms = nil
        @_is_extendable = nil
      end

      # If spec is simple (H2 or HCl for example) then true or false overwise
      # @return [Boolean] is current spec simple?
      def simple?
        if @atoms.empty?
          raise 'The specie does not contain any atom and cannot be simple or complex'
        else
          @atoms.values.all? { |a| a.valence == 1 }
        end
      end

      # The spec is not termination by default
      # @return [Boolean] false
      def termination?
        false
      end

      # @return [Boolean]
      def specific?
        false
      end

      # @return [Boolean] has been specie extended or not
      def extended?
        @is_extended
      end

      # Returns a instance of atom by passed atom keyname
      # @param [Symbol] keyname the key of atom instnance
      # @return [Atom] the atom or nil
      def atom(keyname)
        @atoms[keyname]
      end

      # Returns a keyname which points to passed atom
      # @param [Atom] atom the atom for which keyname will be found
      # @return [Symbol] the keyname of atom
      def keyname(atom)
        @_keynames_to_atoms ||= @atoms.invert
        @_keynames_to_atoms[atom]
      end

      # Apends atom to spec instance
      # @param [Symbol] atom_keyname the alias of atom in spec
      # @param [Atom] atom the appending atom
      def describe_atom(atom_keyname, atom)
        @atoms[atom_keyname] = atom
        @links[atom] = []
      end

      # Swaps from own to new
      # @param [Atom | AtomReference] from
      # @param [Atom | AtomReference] to
      def swap_atom(from, to)
        raise ArgumentError, 'Incorrect swapping' if @links[from] && @links[to]
        swap_atoms_in!(@links, from, to) if @links[from] && !@links[to]
      end

      # Renames the atom from some keyname to some new keyname (used only in
      #   interpreter for handle spec aliasing case)
      #
      # @param [Symbol] from the keyname which will be renamed
      # @param [Symbol] to the new value of keyname
      def rename_atom(from, to)
        if @atoms[to]
          gkto = generate_keyname(to)
          @atoms[gkto] = @atoms.delete(to)
        end
        @atoms[to] = @atoms.delete(from)
      end

      # Adsorbs atoms and links of another spec
      # @param [Spec] other the adsorbing spec
      # @yield [Symbol, Symbol, Atom] returns a valid keyname for an atom
      def adsorb(other, &block)
        duplicates = other.duplicate_atoms_with_keynames
        duplicates.each do |keyname, atom|
          current_keyname =
            if block_given?
              block[keyname, generate_keyname(keyname), atom]
            else
              @atoms[keyname] ? generate_keyname(keyname) : keyname
            end

          # if block given and returned keyname or block is not given
          describe_atom(current_keyname, atom) if current_keyname
        end
        adsorb_links(other, duplicates)
      end

      # Links atoms together in both directions in links graph
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Bond] instance of link
      # @raise [Atom::IncorrectValence] if links of atom more than it valence
      # @yield if given both atoms will be sent to it
      def link(*atoms, instance, &block)
        first, second = atoms
        block[first, second] if block_given?

        if instance.bond?
          atoms.each do |atom|
            if external_bonds_for(atom) == 0
              raise Atom::IncorrectValence.new(atom)
            end
          end
        end

        link_together(*atoms, instance)
      end

      # Returns links container with replacing atoms by passed hash of atoms and
      # their keynames
      #
      # @param [Hash] kns_to_new_atoms the hash which contain keyname
      #   Symbol of atom key and specific atom as value
      # @return [Hash] links container with replacing atoms
      def links_with_replace_by(kns_to_new_atoms)
        # deep dup @links
        chg_links = @links.map { |atom, rels| [atom, rels.map(&:dup)] }.to_h
        kns_to_new_atoms.each_with_object(chg_links) do |(kn, to), acc|
          from = @atoms[kn]
          swap_atoms_in!(acc, from, to) if from && !acc[to]
        end
      end

      # Summarizes external bonds of all internal atoms
      # @return [Integer] sum of external bonds
      def external_bonds
        if simple?
          2
        else
          atom_instances.reduce(0) { |acc, atom| acc + external_bonds_for(atom) }
        end
      end

      # Checks for atom-references
      # @return [Boolean] true if atom-reference exist or false overwise
      def extendable?
        @_is_extendable ||= atom_instances.any?(&:reference?)
      end

      # Duplicates current spec and extend it duplicate by atom-references
      # @return [Spec] extended spec
      # TODO: necessary to consider crystal lattice
      def extend_by_references
        extendable_spec = self.class.new("extended_#{@name}".to_sym)
        extendable_spec.adsorb(self)
        extendable_spec.extend!
        extendable_spec
      end

      # For the common interface with SpecificSpec
      # @return [Array] the empty array
      def specific_atoms
        []
      end

      # Checks termination atom at the inner atom which belongs to current spec
      # @param [Atom | SpecificAtom] internal_atom the atom which belongs to
      #   current spec
      # @param [TerminationSpec] term_spec the termination specie
      # @return [Boolean] has termination atom or not
      def has_termination?(internal_atom, term_spec)
        term_spec.hydrogen? && external_bonds_for(internal_atom) > 0
      end

      # Checks that other spec has same atoms and links between them
      # @param [Spec | SpecificSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        if other.is_a?(VeiledSpec)
          other.same?(self)
        else
          equal?(other) || (links.size == other.links.size &&
            Mcs::SpeciesComparator.contain?(self, other, collaps_multi_bond: true))
        end
      end

      def to_s(instance_atoms = @atoms, instance_links = @links)
        atoms_to_keynames = instance_atoms.invert
        name_with_keyname = -> atom do
          "#{atom}(#{atoms_to_keynames[atom]})"
        end

        str = "#{name}(\n"
        str << instance_links.map do |atom, list|
          links = "  #{name_with_keyname[atom]}[\n    "
          link_strs = list.map do |neighbour, link|
            "#{link}#{name_with_keyname[neighbour]}"
          end
          links << link_strs.join(', ') << ']'
          links
        end.join(",\n")
        str << "\n)"
        str
      end

      def inspect
        name.to_s
      end

    protected

      # Returns hash of duplicated atoms with keys as correspond keynames
      # @return [Hash] hash of duplicated atoms with correspond keynames
      def duplicate_atoms_with_keynames
        Hash[@atoms.map { |keyname, atom| [keyname, atom.dup] }]
      end

      # Extends spec by atom-references
      def extend!
        atom_references = @atoms.select { |_, atom| atom.reference? }
        atom_references.each do |original_keyname, ref|
          adsorb(ref.spec) do |keyname, generated_keyname, atom|
            if keyname == ref.keyname
              # exchange old atom (reference) to new atom
              @atoms[original_keyname] = atom
              swap_atoms_in!(@links, ref, atom)
              nil
            else
              :"#{generated_keyname}_"
            end
          end
        end
        @is_extended = true
      end

    private

      # Returns instances of each described atom
      # @return [Array] the array of atom instances
      def atom_instances
        @links.keys
      end

      # Adsorbs all links from another spec with exchange atoms to they duplicates
      # @param [Spec] other_spec the other spec links of which will be adsrobed
      # @param [Hash] duplicates the hash of duplicates which same as was
      #   returned from #duplicate_atoms_with_keynames method
      def adsorb_links(other_spec, duplicates)
        original_to_duplicates = other_spec.atoms.map do |keyname, atom|
          [atom, duplicates[keyname]]
        end
        original_to_duplicates = Hash[original_to_duplicates]

        other_spec.links.each do |atom, links|
          @links[original_to_duplicates[atom]] +=
            links.map do |another_atom, link_instance|
              [original_to_duplicates[another_atom], link_instance]
            end
        end
      end

      # Generates the new keyname by original keyname with adding a '_' symbol
      # before original keyname and append unique (for current spec) number
      #
      # @param [Symbol] original_keyname the original keyname from which will
      #   be generated new keyname
      # @return [Symbol] generated unique keyname
      def generate_keyname(original_keyname)
        keyname = nil
        prefix, name, i, suffix =
          original_keyname.to_s.scan(/\A(_)?(\D+)(\d+)?(_)?\Z/).first

        i = i ? i.to_i : 0
        prefix ||= '_'

        begin
          keyname = "#{prefix}#{name}#{i}#{suffix}".to_sym
          i += 1
        end while atom(keyname) || (!suffix && atom(:"#{keyname}_"))
        keyname
      end
    end

  end
end
