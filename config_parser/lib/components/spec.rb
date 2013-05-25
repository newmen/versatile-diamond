module VersatileDiamond

  # The class instance contains atoms and bonds between them.
  # When one spec uses an other then atoms and bonds from another spec coping to original spec.
  # If spec is recursive (i.e. uses itself) then no copy, reference to used atom creates instead.
  class Spec < Component
    include AtomMatcher
    include Linker

    class << self
      include SyntaxChecker

      def add(spec_name)
        @@common_specs ||= {}
        syntax_error('spec.already_defined', name: spec_name) if @@common_specs[spec_name]
        @@common_specs[spec_name] = new(spec_name)
      end

      def [](spec_name)
        @@common_specs[spec_name] || syntax_error('spec.undefined', name: spec_name)
      end

      # def visit_all(visitor)
      #   @@common_specs.each { |_, spec| spec.visit(visitor) }
      # end
    end

    attr_reader :name

    def initialize(name)
      @name = name
      @atoms, @links = {}, {}
    end

    def aliases(**refs)
      @aliases_to_atoms ||= {}
      @aliases_to_specs ||= {}
      refs.each do |keyname, spec_name|
        spec = Spec[spec_name.to_sym]
        duplicated_atoms = spec.duplicate_atoms
        adsorb_links(spec.links, duplicated_atoms)
        @aliases_to_atoms[keyname] = spec.alias_atoms(duplicated_atoms)
        @aliases_to_specs[keyname] = spec
      end
    end

    def atoms(**refs)
      refs.each do |keyname, atom|
        real_atom = detect_atom(atom)
        @atoms[keyname] = real_atom
        @links[real_atom] ||= []
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
        internal_bonds = atoms.reduce(0) { |acc, atom| acc + internal_bonds_for(atom) }
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
      rescue AnalyzingError
        extendable_spec = self.class.add(extended_name)
        duplicated_atoms = duplicate_atoms
        extendable_spec.instance_variable_set(:@atoms, alias_atoms(duplicated_atoms))
        extendable_spec.adsorb_links(@links, duplicated_atoms)
        extendable_spec.extend!
        extendable_spec.add_dependency(self)
      end
      extendable_spec
    end

    def [](atom_keyname)
      @atoms[atom_keyname] || syntax_error('spec.undefined_atom_keyname', atom_keyname: atom_keyname, spec_name: @name)
    end

    def to_s
      atoms_to_keynames = @atoms.invert
      name_with_keyname = -> atom { (a = atoms_to_keynames[atom]) ? "#{atom}(#{a})" : "#{atom}" }

      str = "#{name}(\n"
      str << @links.map do |atom, list|
        links = "  #{name_with_keyname[atom]}[\n    "
        links << list.map { |neighbour, link| "#{link}#{name_with_keyname[neighbour]}" }.join(', ')
        links << ']'
        links
      end.join(",\n")
      str << ')'
      str
    end

    def visit(visitor)
      visitor.accept_spec(self)
    end

    def reorganize_dependencies(used_specs, links = @links)
      possible_children = used_specs.reject { |s| s.links.size > links.size }.sort_by { |s| s.links.size }.reverse

      possible_children.each do |possible_child|
        break if @dependent_from && @dependent_from.include?(possible_child)
        if remainder_links = contain?(links, possible_child.links)
          @dependent_from.clear if links == @links && @dependent_from
          add_dependency(possible_child)
          reorganize_dependencies(possible_children, remainder_links) if remainder_links.size > 0
          break
        end
      end
    end

  protected

    attr_reader :links

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
      atom_references = atom_instances.select { |atom| atom.is_a?(AtomReference) }
      ref_dup_atoms = Hash[atom_references.map { |atom_ref| [atom_ref, atom_ref.spec.duplicate_atoms] }]

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
        @links[ref_dup_atoms[atom_ref][atom_ref.atom]] = @links.delete(atom_ref)
      end

      # excange internal @links AtomReference instances to duplicated Atom inatances
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
      atom_references.each { |atom_ref| adsorb_links(atom_ref.spec.links, ref_dup_atoms[atom_ref]) }
    end

    def add_dependency(parent_spec)
      @dependent_from ||= Set.new
      @dependent_from << parent_spec
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
        add_dependency(self)
        AtomReference.new(self, atom_keyname)
      elsif @aliases_to_atoms && (alias_to_atoms = @aliases_to_atoms[spec_name])
        add_dependency(@aliases_to_specs[spec_name])
        alias_to_atoms[atom_keyname]
      else
        spec = Spec[spec_name]
        add_dependency(spec)
        duplicated_atoms = spec.duplicate_atoms
        adsorb_links(spec.links, duplicated_atoms)
        duplicated_atoms[spec[atom_keyname]]
      end
    end

    def link(klass, *atom_keynames, **options)
      first, second = existing_atoms(*atom_keynames)
      yield(first, second) if block_given?
      instance = klass[options]
      super(:@links, first, second, instance)
    end

    def existing_atoms(*atom_keynames)
      atom_keynames.map { |atom_keyname| self.[](atom_keyname) }
    end

    def internal_bonds_for(atom)
      @links[atom].select { |_, link_instance| link_instance.class == Bond }.size
    end

    def contain?(large_links, small_links)
      s_atom, s_links_list = small_links.first
      large_links.each do |l_atom, l_links_list|
        # if s_atom == l_atom &&

      end
    end
  end

end
