module VersatileDiamond
  module Concepts

    # The class instance contains atoms and bonds between them.
    # When one spec uses an other then atoms and bonds from another spec coping
    # to original spec.
    # If spec is recursive (i.e. uses itself) then no copy, reference to used
    # atom creates instead.
    class Spec < Base
      attr_reader :name, :links

      def initialize(name)
        @name = name
        @atoms, @links = {}, {}
      end

      # def simple?
      #   @is_simple
      # end

      # def aliases(**refs)
      #   @aliases_to_atoms ||= {}
      #   @aliases_to_specs ||= {}
      #   refs.each do |keyname, spec_name|
      #     spec = Spec[spec_name.to_sym]
      #     duplicated_atoms = spec.duplicate_atoms
      #     adsorb_links(spec.links, duplicated_atoms)

      #     @aliases_to_atoms[keyname] = spec.alias_atoms(duplicated_atoms)
      #     @aliases_to_specs[keyname] = spec
      #   end
      # end

      def atoms(**refs)
        refs.each do |keyname, atom|
          real_atom = detect_atom(atom)
          @atoms[keyname] = real_atom
          @links[real_atom] ||= []
        end

        if refs.size == 1 && @atoms.values.first.valence == 1
          @is_simple = true
        end
      end

      def bond(first, second, **options)
        link(Bond, first, second, options)
      end

      def dbond(first, second)
        2.times { bond(first, second) }
      end

      # another methods

      def external_bonds
        atoms = atom_instances
        valences = atoms.map(&:valence)
        if valences.size == 1 && valences.first == 1
          2
        else
          internal_bonds = atoms.reduce(0) do |acc, atom|
            acc + internal_bonds_for(atom)
          end
          valences.reduce(:+) - internal_bonds
        end
      end

      def external_bonds_for(atom_keyname)
        atom = @atoms[atom_keyname]
        atom.valence - internal_bonds_for(atom)
      end

      def extendable?
        @extendable ||= atom_instances.any? { |atom| atom.is_a?(AtomReference) }
      end

      def extend_by_references
        extended_name = "extended_#{@name}"
        begin
          extendable_spec = Spec[extended_name]
        rescue AnalyzingError # TODO: strange checking
          extendable_spec = self.class.add(extended_name)
          duplicated_atoms = duplicate_atoms
          extendable_spec.instance_variable_set(
            :@atoms, alias_atoms(duplicated_atoms))
          extendable_spec.adsorb_links(@links, duplicated_atoms)
          extendable_spec.extend!
          extendable_spec.dependent_from << self
        end
        extendable_spec
      end

      def [](atom_keyname)
        @atoms[atom_keyname] ||
          syntax_error('spec.undefined_atom_keyname',
            atom_keyname: atom_keyname, spec_name: @name)
      end

      def keyname(atom)
        @atoms.invert[atom]
      end

      def to_s
        atoms_to_keynames = @atoms.invert
        name_with_keyname = -> atom do
          (a = atoms_to_keynames[atom]) ? "#{atom}(#{a})" : "#{atom}"
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

      def visit(visitor)
        visitor.accept_spec(self)
      end

      def dependent_from
        @dependent_from ||= Set.new
      end

      def reorganize_dependencies(used_specs, links = @links)
        # select and sort possible chilren
        possible_parents = used_specs.select do |s|
          s.name != @name && (s.links.size < links.size ||
            (s.links.size == links.size && s.external_bonds > external_bonds))
        end
        possible_parents.sort! do |a, b|
          if a.links.size == b.links.size
            a.external_bonds <=> b.external_bonds
          else
            b.links.size <=> a.links.size
          end
        end

        # find and reorganize dependencies
        possible_parents.each do |possible_parent|
          if dependent_from.include?(possible_parent) ||
            contain?(links, possible_parent.links)

            dependent_from.clear
            dependent_from << possible_parent
            break
          end
        end

        # clear dependecies if dependent only from itself
        if dependent_from.size == 1 && dependent_from.include?(self)
          dependent_from.clear
        end
      end

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

    protected

      def duplicate_atoms
        atoms = atom_instances
        Hash[atoms.zip(atoms.map(&:dup))]
      end

      def adsorb_links(readsorbed_links, duplicated_atoms)
        readsorbed_links.each do |atom, links|
          duplicated_atom = duplicated_atoms[atom]
          @links[duplicated_atom] ||= []
          @links[duplicated_atom] += links.map do |another_atom, bond_instance|
            [duplicated_atoms[another_atom], bond_instance]
          end
        end
      end

      def alias_atoms(duplicated_atoms)
        Hash[@atoms.map { |key, atom| [key, duplicated_atoms[atom]] }]
      end

      def extend!
        atom_references = atom_instances.select do |atom|
          atom.is_a?(AtomReference)
        end

        ref_dup_atoms = Hash[atom_references.map do |atom_ref|
          [atom_ref, atom_ref.spec.duplicate_atoms]
        end]

        # exchange values of @atoms if value is a AtomReference
        @atoms = Hash[@atoms.map do |atom_keyname, atom|
          if atom.is_a?(AtomReference)
            [atom_keyname, ref_dup_atoms[atom][atom.atom]]
          else
            [atom_keyname, atom]
          end
        end]

        # exchange @links AtomReference keys to duplicated Atom instance keys
        atom_references.each do |atom_ref|
          @links[ref_dup_atoms[atom_ref][atom_ref.atom]] =
            @links.delete(atom_ref)
        end

        # excange internal @links AtomReference instances to
        # duplicated Atom inatances
        @links.values.each do |links|
          links.map! do |another_atom, link_instance|
            if another_atom.is_a?(AtomReference)
              [ref_dup_atoms[another_atom][another_atom.atom], link_instance]
            else
              [another_atom, link_instance]
            end
          end
        end

        # adsorb remaining atoms and links between them
        atom_references.each do |atom_ref|
          adsorb_links(atom_ref.spec.links, ref_dup_atoms[atom_ref])
        end
      end

    private

      def atom_instances
        @links.keys
      end

      def detect_atom(atom_str)
        simple_atom(atom_str) || used_atom(atom_str)
      end

      def simple_atom(atom_str)
        if (atom_name = Matcher.atom(atom_str))
          Atom[atom_name]
        end
      end

      def used_atom(atom_str)
        spec_name, atom_keyname = match_used_atom(atom_str)
        if spec_name == @name
          dependent_from << self
          AtomReference.new(self, atom_keyname)
        elsif @aliases_to_atoms &&
          (alias_to_atoms = @aliases_to_atoms[spec_name])

          dependent_from << @aliases_to_specs[spec_name]
          alias_to_atoms[atom_keyname]
        else
          spec = Spec[spec_name]
          dependent_from << spec
          duplicated_atoms = spec.duplicate_atoms
          adsorb_links(spec.links, duplicated_atoms)
          duplicated_atoms[spec[atom_keyname]]
        end
      end

      def link(klass, *atom_keynames, **options, &block)
        first, second = existing_atoms(*atom_keynames)
        block[first, second] if block_given?
        instance = klass[options]

        @links ||= {}
        @links[first] ||= []
        @links[first] << [second, instance]
        @links[second] ||= []
        @links[second] << [first, instance]
      end

      def existing_atoms(*atom_keynames)
        atom_keynames.map { |atom_keyname| self.[](atom_keyname) }
      end

      def internal_bonds_for(atom)
        bonds = @links[atom].select do |_, link_instance|
          link_instance.class == Bond
        end
        bonds.size
      end

      def contain?(large_links, small_links)
        HanserRecursiveAlgorithm.contain?(large_links, small_links)
      end
    end

  end
end
