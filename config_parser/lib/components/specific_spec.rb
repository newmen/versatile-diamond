module VersatileDiamond

  class SpecificSpec
    extend Forwardable
    include ArgumentsParser
    include SyntaxChecker

    attr_reader :spec

    def initialize(spec_str)
      @original_name, @options = name_and_options(spec_str)
      @spec = Spec[@original_name]

      grouped_opts = @options.group_by { |atom_keyname, _| atom_keyname }
      grouped_opts.each do |atom_keyname, opts|
        free_bonds_num = @spec.external_bonds_for(atom_keyname)
        if (free_bonds_num - opts.count { |_, value| value == '*' }) < 0
          syntax_error('.invalid_actives_num',
            atom: atom_keyname, spec: @original_name, nums: free_bonds_num)
        end
      end
    end

    def initialize_copy(other)
      @options = other.instance_variable_get(:@options).dup
    end

    def_delegators :@spec, :extendable?, :simple?

    def name
      @original_name
    end

    def external_bonds
      @spec.external_bonds - active_bonds_num
    end

    %w(incoherent unfixed).each do |state|
      define_method(state) do |atom_keyname|
        if @spec[atom_keyname]
          same_state = @options.find do |akn, st|
            akn == atom_keyname && st == state.to_sym
          end
          if same_state
            syntax_error('.atom_already_has_state',
              spec: @original_name, atom: atom_keyname, state: state)
          end

          @options << [atom_keyname, state.to_sym]
        end
      end
    end

    def is_gas?
      Gas.instance.include?(@spec)
    end

    def external_bonds_after_extend
      return @external_bonds_after_extend if @external_bonds_after_extend
      @extended_spec = @spec.extend_by_references
      @external_bonds_after_extend =
        @extended_spec.external_bonds - active_bonds_num
    end

    def extend!
      @spec = @extended_spec
    end

    def changed_atoms(other)
      actives, other_actives = only_actives, other.only_actives
      actives.reject! do |atom_state|
        i = other_actives.index(atom_state)
        i && other_actives.delete_at(i)
      end

      (actives + other_actives).map { |atom_keyname, _| @spec[atom_keyname] }
    end

    def to_s
      opts = @options.map do |atom_keyname, value|
        v = case value
          when :incoherent then 'i'
          when :unfixed then 'u'
          else value
          end
        "#{atom_keyname}: #{v}"
      end
      "#{@spec.name}(#{opts.join(', ')})"
    end

    def visit(visitor)
      @spec.visit(visitor)
      visitor.accept_specific_spec(self)
    end

    def same?(other)
      other == self ||
        ((self.is_a?(other.class) || other.is_a?(self.class)) &&
          @spec == other.spec &&
            (@options == other.options || (!@options.empty? &&
              @options.size == other.options.size && correspond?(other))))
    end

    def organize_dependencies(similar_specs)
      similar_specs = similar_specs.reject do |s|
        s.options.size >= @options.size
      end
      similar_specs = similar_specs.sort do |a, b|
        b.options.size <=> a.options.size
      end

      max_opts_size = -1
      @dependent_from = similar_specs.select do |ss|
        max_opts_size <= ss.options.size &&
          ((active? && ss.active?) || !(active? || ss.active?)) &&
          ss.options.all? { |option| @options.include?(option) } &&
          (max_opts_size = ss.options.size)
      end
    end

    def dependent_from
      @dependent_from && @dependent_from.first
    end

    def active?
      active_bonds_num > 0
    end

    def has_atom?(atom)
      (Atom.is_hydrogen?(atom) && @spec.external_bonds > 0) ||
        @spec.links.keys.find { |spec_atom| spec_atom.same?(atom) }
    end

    def look_around(atom_map)
      return if is_gas?

      # TODO: need to check unfixing

      atom_map.each do |specs, corrs|
        next unless specs.any? { |spec| spec == self }

        source, _ = specs
        xs = self == source ? [0, 1] : [1, 0]
        corrs.each do |mirror|
          atoms_with_links = specs.zip(mirror).map do |specific_spec, atom|
            [specific_spec, specific_spec[atom], specific_spec.links_of(atom)]
          end

          _, own, incedent_bonds = atoms_with_links[xs.first]
          other, foreign, _ = atoms_with_links[xs.last]

          diff = own.diff(foreign)
          is_osa = own.is_a?(SpecificAtom)
          keyname = @spec.keyname(is_osa ? own.atom : own)
          own = SpecificAtom.new(own) unless is_osa

# puts "???? #{name}[#{keyname}]: #{diff.inspect}" unless diff.empty?

          # TODO: if atom has not remain bonds - to clean up the incidence
          if own.incoherent?
            diff -= [:incoherent]
          elsif other.is_gas?
            diff << :incoherent
          end

          if own.unfixed? || incedent_bonds.size > 1
            diff -= [:unfixed]
          elsif incedent_bonds.size == 1 && !own.lattice
            diff << :unfixed
          end

          unless diff.empty?
# puts "++++ #{name}[#{keyname}]: #{diff.inspect}"
            diff.each { |d| @options << [keyname, d] }
            expire_caches!
          end
        end
      end
    end

  protected

    attr_reader :options

    def links_with_specific_atoms
      @links_with_specific_atoms ||=
        @spec.links_with_replace_by(keynames_to_specific_atoms)
    end

    def only_actives
      @options.select { |_, value| value == '*' }
    end

    def [](atom)
      unless @atoms_to_specific_atoms
        @atoms_to_specific_atoms = {}
        each_specific_atom do |original_atom, specific_atom|
          @atoms_to_specific_atoms[original_atom] = specific_atom
        end
      end

      @atoms_to_specific_atoms[atom] || atom
    end

    def links_of(atom)
      links_with_specific_atoms[self.[](atom)].select do |_, link|
        link.class == Bond
      end
    end

  private

    def name_and_options(spec_str)
      name, args_str = Matcher.specified_spec(spec_str)
      opts = []
      if args_str && args_str != ''
        extract_hash_args(args_str) do |key, value|
          case value
          when 'i', 'u'
            opts << [key, (value == 'i' ? :incoherent : :unfixed)]
          when /\A\*+\Z/
            value.scan('*').size.times do
              opts << [key, '*']
            end
          else syntax_error('.wrong_specification')
          end
        end
      end

      [name.to_sym, opts]
    end

    def active_bonds_num
      only_actives.size
    end

    def keynames_to_specific_atoms
      @keynames_to_specific_atoms ||=
        @options.each_with_object({}) do |(atom_keyname, value), hash|
          specific_atom = hash[atom_keyname] ||
            SpecificAtom.new(@spec[atom_keyname])

          case value
          when :incoherent then specific_atom.incoherent!
          when :unfixed then specific_atom.unfixed!
          when '*' then specific_atom.active!
          end

          hash[atom_keyname] = specific_atom
        end
    end

    def each_specific_atom(&block)
      keynames_to_specific_atoms.each do |atom_keyname, specific_atom|
        block[@spec[atom_keyname], specific_atom]
      end
    end

    def expire_caches!
      @atoms_to_specific_atoms = nil
      @keynames_to_specific_atoms = nil
      @links_with_specific_atoms = nil
    end

    def correspond?(other)
      HanserRecursiveAlgorithm.contain?(
        links_with_specific_atoms, other.links_with_specific_atoms)
    end
  end

end
