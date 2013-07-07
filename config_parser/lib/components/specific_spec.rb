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
      (self.is_a?(other.class) || other.is_a?(self.class)) &&
        @spec == other.spec &&
          (@options == other.options || (!@options.empty? &&
            @options.size == other.options.size && correspond?(other)))
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
      @spec.links.keys.find { |spec_atom| spec_atom.same?(atom) }
    end

  protected

    attr_reader :options

    def links_with_specific_atoms
      return @links_with_specific_atoms if @links_with_specific_atoms

      specific_atoms =
        @options.each_with_object({}) do |(atom_keyname, value), hash|
          hash[atom_keyname] ||= SpecificAtom.new(@spec[atom_keyname])
          specific_atom = hash[atom_keyname]

          case value
          when :incoherent then specific_atom.incoherent!
          when :unfixed then specific_atom.unfixed!
          when '*' then specific_atom.active!
          end
        end

      @links_with_specific_atoms = @spec.links_with_replace_by(specific_atoms)
    end

    def only_actives
      @options.select { |_, value| value == '*' }
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

    def correspond?(other)
      HanserRecursiveAlgorithm.contain?(
        links_with_specific_atoms, other.links_with_specific_atoms)
    end
  end

end
