module VersatileDiamond
  module Concepts

    # The class instance contains atoms and bonds between them.
    class Spec < Base

      # Creates [Symbol]Atom as atoms and [Atom][[Atom, Bond]] as links
      # @param [Symbol] name the name of spec
      # @param [Hash] atoms the associated array [Symbol]Atom
      def initialize(name, atoms = {})
        super(name)
        @atoms, @links = {}, {}
        atoms.each { |k, a| describe_atom(k, a) }
      end

      # If spec is simple (H2 or HCl for example) then true or false
      # @return [Boolean] current spec is simple?
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
          @links[original_to_duplicates[atom]] =
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

      # def external_bonds
      #   atoms = atom_instances
      #   valences = atoms.map(&:valence)
      #   if valences.size == 1 && valences.first == 1
      #     2
      #   else
      #     internal_bonds = atoms.reduce(0) do |acc, atom|
      #       acc + internal_bonds_for(atom)
      #     end
      #     valences.reduce(:+) - internal_bonds
      #   end
      # end

      # def extendable?
      #   @extendable ||= atom_instances.any? { |atom| atom.is_a?(AtomReference) }
      # end

      # def extend_by_references
      #   extended_name = "extended_#{@name}"
      #   begin
      #     extendable_spec = Spec[extended_name]
      #   rescue AnalyzingError # TODO: strange checking
      #     extendable_spec = self.class.add(extended_name)
      #     duplicated_atoms = duplicate_atoms
      #     extendable_spec.instance_variable_set(
      #       :@atoms, alias_atoms(duplicated_atoms))
      #     extendable_spec.adsorb_links(@links, duplicated_atoms)
      #     extendable_spec.extend!
      #     extendable_spec.dependent_from << self
      #   end
      #   extendable_spec
      # end

      # def keyname(atom)
      #   @atoms.invert[atom]
      # end

      # def to_s
      #   atoms_to_keynames = @atoms.invert
      #   name_with_keyname = -> atom do
      #     (a = atoms_to_keynames[atom]) ? "#{atom}(#{a})" : "#{atom}"
      #   end

      #   str = "#{name}(\n"
      #   str << @links.map do |atom, list|
      #     links = "  #{name_with_keyname[atom]}[\n    "
      #     link_strs = list.map do |neighbour, link|
      #       "#{link}#{name_with_keyname[neighbour]}"
      #     end
      #     links << link_strs.join(', ') << ']'
      #     links
      #   end.join(",\n")
      #   str << "\n)"
      #   str
      # end

      # def visit(visitor)
      #   visitor.accept_spec(self)
      # end

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

      # def links_with_replace_by(keynames_to_new_atoms)
      #   # deep dup @links
      #   replaced_links = Hash[@links.map do |atom, links|
      #     [atom, links.map.to_a]
      #   end]

      #   keynames_to_new_atoms.each do |replaced_atom_keyname, new_atom|
      #     replaced_atom = @atoms[replaced_atom_keyname]
      #     local_links = replaced_links.delete(replaced_atom)
      #     local_links.each do |linked_atom, _|
      #       replaced_links[linked_atom].map! do |atom, link|
      #         [(atom == replaced_atom ? new_atom : atom), link]
      #       end
      #     end
      #     replaced_links[new_atom] = local_links
      #   end

      #   replaced_links
      # end

    protected

      attr_reader :atoms, :links

      # def extend!
      #   atom_references = atom_instances.select do |atom|
      #     atom.is_a?(AtomReference)
      #   end

      #   ref_dup_atoms = Hash[atom_references.map do |atom_ref|
      #     [atom_ref, atom_ref.spec.duplicate_atoms]
      #   end]

      #   # exchange values of @atoms if value is a AtomReference
      #   @atoms = Hash[@atoms.map do |atom_keyname, atom|
      #     if atom.is_a?(AtomReference)
      #       [atom_keyname, ref_dup_atoms[atom][atom.atom]]
      #     else
      #       [atom_keyname, atom]
      #     end
      #   end]

      #   # exchange @links AtomReference keys to duplicated Atom instance keys
      #   atom_references.each do |atom_ref|
      #     @links[ref_dup_atoms[atom_ref][atom_ref.atom]] =
      #       @links.delete(atom_ref)
      #   end

      #   # excange internal @links AtomReference instances to
      #   # duplicated Atom inatances
      #   @links.values.each do |links|
      #     links.map! do |another_atom, link_instance|
      #       if another_atom.is_a?(AtomReference)
      #         [ref_dup_atoms[another_atom][another_atom.atom], link_instance]
      #       else
      #         [another_atom, link_instance]
      #       end
      #     end
      #   end

      #   # adsorb remaining atoms and links between them
      #   atom_references.each do |atom_ref|
      #     adsorb_links(atom_ref.spec.links, ref_dup_atoms[atom_ref])
      #   end
      # end

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
        bonds = @links[atom].select do |_, link|
          link.class == Bond
        end
        bonds.size
      end

      def contain?(large_links, small_links)
        HanserRecursiveAlgorithm.contain?(large_links, small_links)
      end
    end

  end
end
