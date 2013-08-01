module VersatileDiamond
  module Concepts

    # The class instance contains atoms and bonds between them.
    class Spec < Named
      include Modules::KeynameGenerator

      # Creates [Symbol]Atom as atoms and [Atom][[Atom, Bond]] as links
      # @param [Symbol] name the name of spec
      # @param [Hash] atoms the associated array [Symbol]Atom
      def initialize(name, atoms = {})
        super(name)
        @atoms, @links = {}, {}
        atoms.each { |k, a| describe_atom(k, a) }
      end

      # If spec is simple (H2 or HCl for example) then true or false
      # @return [Boolean] is current spec simple?
      def simple?
        @is_simple
      end

      # Returns a instance of atom by passed atom keyname
      # @param [Symbol] atom_keyname the key of atom instnance
      # @return [Atom] the atom or nil
      def atom(atom_keyname)
        @atoms[atom_keyname]
      end

      # Returns hash of duplicated atoms with keys as correspond keynames
      # @return [Hash] hash of duplicated atoms with correspond keynames
      def duplicate_atoms_with_keynames
        Hash[@atoms.map { |keyname, atom| [keyname, atom.dup] }]
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
        @atoms[to] = @atoms.delete(from)
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

        @links[first] << [second, instance]
        @links[second] << [first, instance]
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

      # Counts external bonds for atom
      # @param [Atom] atom the atom for wtich need to count bonds
      # @return [Integer] number of bonds
      def external_bonds_for(atom)
        atom.valence - internal_bonds_for(atom)
      end

      # Summarizes external bonds of all internal atoms
      # @return [Integer] sum of external bonds
      def external_bonds
        if simple?
          0
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
      def extend_by_references
        extended_name = "extended_#{@name}".to_sym
        begin # caching
          Tools::Chest.spec(extended_name)
        rescue Tools::Chest::KeyNameError
          duplicates = duplicate_atoms_with_keynames
          extendable_spec = self.class.new(extended_name, duplicates)
          extendable_spec.adsorb_links(self, duplicates)
          extendable_spec.dependent_from << self
          extendable_spec.extend!

          Tools::Chest.store(extendable_spec)
          extendable_spec
        end
      end

      # def keyname(atom)
      #   @atoms.invert[atom]
      # end

      # def visit(visitor)
      #   visitor.accept_spec(self)
      # end

      # TODO: rspec and doc
      def dependent_from
        @dependent_from ||= Set.new
      end

      # def reorganize_dependencies(used_specs, links = @links)
      #   # select and sort possible chilren
      #   possible_parents = used_specs.select do |s|
      #     s.name != @name && (s.links.size < links.size ||
      #       (s.links.size == links.size && s.external_bonds > external_bonds))
      #   end
      #   possible_parents.sort! do |a, b|
      #     if a.links.size == b.links.size
      #       a.external_bonds <=> b.external_bonds
      #     else
      #       b.links.size <=> a.links.size
      #     end
      #   end

      #   # find and reorganize dependencies
      #   possible_parents.each do |possible_parent|
      #     if dependent_from.include?(possible_parent) ||
      #       contain?(links, possible_parent.links)

      #       dependent_from.clear
      #       dependent_from << possible_parent
      #       break
      #     end
      #   end

      #   # clear dependecies if dependent only from itself
      #   if dependent_from.size == 1 && dependent_from.include?(self)
      #     dependent_from.clear
      #   end
      # end

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

      def to_s
        atoms_to_keynames = @atoms.invert
        name_with_keyname = -> atom do
          "#{atom}(#{atoms_to_keynames[atom]})"
        end

        str = "#{name}(\n"
        str << @links.map do |atom, list|
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

    protected

      attr_reader :atoms, :links

      # Extends spec by atom-references
      def extend!
        atom_references = @atoms.select do |_, atom|
          atom.is_a?(AtomReference)
        end

        atom_references.each do |original_keyname, ref|
          duplicates = ref.spec.duplicate_atoms_with_keynames
          duplicates.each do |keyname, atom|
            if keyname == ref.keyname
              # exchange old atom (reference) to new atom
              @atoms[original_keyname] = atom
              links = @links.delete(ref)
              links.each do |another_atom, link|
                @links[another_atom].map! do |aa, al|
                  [(aa == ref ? atom : aa), al]
                end
              end
              @links[atom] = links
            else
              # generate keyname and adsorb new atom
              keyname = generate_keyname(self, keyname)
              describe_atom(keyname, atom)
            end
          end

          adsorb_links(ref.spec, duplicates)
        end
      end

    private

      # Returns instances of each described atom
      # @return [Array] the array of atom instances
      def atom_instances
        @links.keys
      end

      # Counts internal bonds for atom
      # @param [Atom] atom the atom for wtich need to count bonds
      # @return [Integer] number of bonds
      def internal_bonds_for(atom)
        bonds = @links[atom].select { |_, link| link.class == Bond }
        bonds.size
      end

      def contain?(large_links, small_links)
        HanserRecursiveAlgorithm.contain?(large_links, small_links)
      end
    end

  end
end
