module VersatileDiamond

  class SpecificSpec
    extend Forwardable
    include ArgumentsParser
    include SyntaxChecker

    attr_reader :spec

    def initialize(spec_str)
      @original_name, @options = name_and_options(spec_str)
      @spec = Spec[@original_name]
      @options.each { |atom_keyname, _| @spec[atom_keyname] } # raises syntax error if atom_keyname undefined
    end

    def initialize_copy(other)
      @options = other.instance_variable_get(:@options).dup
    end

    def_delegators :@spec, :[], :extendable?

    def name
      @original_name
    end

    def external_bonds
      @spec.external_bonds - active_bonds_num
    end

    %w(incoherent unfixed).each do |state|
      define_method(state) do |atom_keyname|
        if @spec[atom_keyname] # condition raise syntax_error if atom_keyname undefined
          if @options.find { |akn, st| akn == atom_keyname && st == state.to_sym }
            syntax_error('.atom_already_has_state', spec: @original_name, atom: atom_keyname, state: state)
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
      @external_bonds_after_extend = @extended_spec.external_bonds - active_bonds_num
    end

    def extend!
      @spec = @extended_spec
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
      @spec == other.spec && (@options == other.options ||
        (@options.size == other.options.size && !(@options.empty? || other.options.empty?) && correspond?(other)))
    end

    def organize_dependencies(similar_specs)
      similar_specs = similar_specs.reject { |s| s.options.size >= @options.size }.
        sort { |a, b| b.options.size <=> a.options.size }

      max_opts_size = -1
      @dependent_from = similar_specs.select do |ss|
        max_opts_size <= ss.options.size && ((active_bonds_num > 0 && ss.active_bonds_num > 0) ||
            (active_bonds_num == 0 && ss.active_bonds_num == 0)) &&
          ss.options.reduce(true) { |acc, option| acc && @options.include?(option) } &&
          (max_opts_size = ss.options.size)
      end
    end

    def dependent_from
      @dependent_from && @dependent_from.first
    end

  protected

    attr_reader :options

    def links_with_concrete_atoms
      return @links_with_concrete_atoms if @links_with_concrete_atoms
      params = {}
      @options.each do |atom_keyname, value|
        specific_atom = (params[atom_keyname] ||= SpecificAtom.new(@spec[atom_keyname]))
        case value
        when :incoherent then specific_atom.incoherent!
        when :unfixed then specific_atom.unfixed!
        when '*' then specific_atom.active!
        end
      end
      @links_with_concrete_atoms = @spec.links_with_replace_by(params)
    end

    def active_bonds_num
      @options.select { |_, value| value == '*' }.size
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

    def correspond?(other)
      HanserRecursiveAlgorithm.contain?(links_with_concrete_atoms, other.links_with_concrete_atoms)
    end
  end

end
