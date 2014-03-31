module VersatileDiamond
  module Concepts

    # The class instance contains atoms and bonds between them.
    # @abstract
    class Spec < Named
      include Visitors::Visitable
      include Linker
      include BondsCounter

      attr_reader :atoms # must be protected!! only for SpecificSpec#to_s
      attr_reader :links

      # Checks that atom keyname suitable for reducing
      # @param [Array] keyname the array of atom keyname which will be checked
      # @return [Boolean] all situable or not
      def self.good_for_reduce?(keynames)
        keynames.all? { |kn| kn =~ /^[^_]/ }
      end

      # Creates [Symbol]Atom as atoms and [Atom][[Atom, Bond]] as links
      # @param [Symbol] name the name of spec
      # @param [Hash] atoms the associated array [Symbol]Atom
      def initialize(name, **atoms)
        super(name)
        @atoms, @links = {}, {}
        atoms.each { |k, a| describe_atom(k, a) }

        @parent, @child, @there = nil
      end

      # If spec is simple (H2 or HCl for example) then true or false
      # @return [Boolean] is current spec simple?
      def simple?
        @is_simple
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
        @atoms.invert[atom]
      end

      # Apends atom to spec instance
      # @param [Symbol] atom_keyname the alias of atom in spec
      # @param [Atom] atom the appending atom
      def describe_atom(atom_keyname, atom)
        @atoms[atom_keyname] = atom
        @links[atom] = []
        @is_simple = (@atoms.size == 1 && atom_instances.first.valence == 1)
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
          current_keyname = block_given? ?
            block[keyname, generate_keyname(keyname), atom] :
            (@atoms[keyname] ? generate_keyname(keyname) : keyname)

          # if block was given and returned keyname or block is not given
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

        if instance.class == Bond
          atoms.each do |atom|
            if external_bonds_for(atom) == 0
              raise Atom::IncorrectValence.new(atom)
            end
          end
        end

        link_together(*atoms, instance)
      end

      # Returns links container with replaced atoms by passed hash of atoms and
      # their keynames
      #
      # @param [Hash] keynames_to_new_atoms the hash which contain keyname
      #   Symbol of atom key and specific atom as value
      # @return [Hash] links container with replaced atoms
      def links_with_replace_by(keynames_to_new_atoms)
        # deep dup @links
        replaced_links = Hash[@links.map do |atom, links|
          [atom, links.map.to_a]
        end]

        keynames_to_new_atoms.each do |replaced_atom_keyname, new_atom|
          replaced_atom = @atoms[replaced_atom_keyname]
          local_links = replaced_links.delete(replaced_atom)
          local_links.each do |linked_atom, _|
            replaced_links[linked_atom].map! do |atom, link|
              [(atom == replaced_atom ? new_atom : atom), link]
            end
          end
          replaced_links[new_atom] = local_links
        end

        replaced_links
      end

      # Summarizes external bonds of all internal atoms
      # @return [Integer] sum of external bonds
      def external_bonds
        if simple?
          2
        else
          atoms = atom_instances
          internal_bonds = atoms.reduce(0) do |acc, atom|
            acc + internal_bonds_for(atom)
          end
          atoms.map(&:valence).reduce(:+) - internal_bonds
        end
      end

      # Checks for atom-references
      # @return [Boolean] true if atom-reference exist or false overwise
      def extendable?
        @extendable ||= atom_instances.any? do |atom|
          atom.is_a?(AtomReference)
        end
      end

      # Duplicates current spec and extend it duplicate by atom-references
      # @return [Spec] extended spec
      # TODO: necessary to consider crystal lattice
      def extend_by_references
        extended_name = "extended_#{@name}".to_sym
        begin # caching
          Tools::Chest.spec(extended_name).dup
        rescue Tools::Chest::KeyNameError
          extendable_spec = self.class.new(extended_name)
          extendable_spec.adsorb(self)
          extendable_spec.extend!
          Tools::Chest.store(extendable_spec)
          extendable_spec
        end
      end

      # Gets parent of current spec
      # @return [Spec] the parent
      def parent
        parents.first
      end

      # Organize dependencies from another specs by containing check
      # @param [Array] possible_parents the array of possible parents in
      #   descending order
      def organize_dependencies!(possible_parents)
        # find and reorganize dependencies
        possible_parents.each do |possible_parent|
          if residue(links, possible_parent.links)
            store_parent(possible_parent)
            parent.store_child(self)
            break
          end
        end
      end

      # Appends a childs to current collection
      # @param [Array] specs the array of appenging childs
      def append_childs(specs)
        childs.concat(specs)
      end

      # Removes a spec from collection of children
      # @param [SpecificSpec] spec the removable child
      def remove_child(spec)
        childs.reject! { |s| s == spec }
      end

      # Gets a number of atoms
      # @return size of current spec
      def size
        atom_instances.size
      end

      # Also visit a parent
      # @param [Visitors::Visitor] visitor the accumulator of states
      # @override
      def visit(visitor)
        super
        parent.visit(visitor) if parent
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
        atom_references = @atoms.select do |_, atom|
          atom.is_a?(AtomReference)
        end

        atom_references.each do |original_keyname, ref|
          adsorb(ref.spec) do |keyname, generated_keyname, atom|
            if keyname == ref.keyname
              # exchange old atom (reference) to new atom
              @atoms[original_keyname] = atom
              links = @links.delete(ref)
              links.each do |another_atom, link|
                @links[another_atom].map! do |at, li|
                  [(at == ref ? atom : at), li]
                end
              end
              @links[atom] = links
              nil
            else
              generated_keyname
            end
          end
        end

        reset_caches
      end

    private

      # Returns instances of each described atom
      # @return [Array] the array of atom instances
      def atom_instances
        @links.keys
      end

      # Adsorbs all links from another spec with exchange atoms to they
      #   duplicates
      #
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
        prefix, name, i =
          original_keyname.to_s.scan(/\A(_)?(\D+)(\d+)?\Z/).first

        i = i ? i.to_i : 0
        prefix ||= '_'

        begin
          keyname = "#{prefix}#{name}#{i}".to_sym
          i += 1
        end while atom(keyname)
        keyname
      end

      # The large links contains small links?
      # @param [Hash] large_links the links from large spec
      # @param [Hash] small_links the links from small spec
      # @raise [RuntimeError] if some of multi-bond (in large or small links)
      #   is invalid
      # @return [Boolean] contains or not
      def residue(large_links, small_links)
        HanserRecursiveAlgorithm.contain?(large_links, small_links,
          separated_multi_bond: true)
      end

      # Resets internal caches
      def reset_caches
        @keynames_to_atoms = nil
      end
    end

  end
end
