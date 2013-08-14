module VersatileDiamond
  module Concepts

    # Instance of it class represents usual specific spec that is most commonly
    # used in reactions
    class SpecificSpec
      extend Forwardable

      attr_reader :spec

      # Initialize specific spec instalce. Checks specified atom for correct
      #   valence value
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

      def initialize_copy(other)
        @spec = other.spec
        @specific_atoms = Hash[other.specific_atoms.map { |k, a| [k, a.dup] }]
      end

      def_delegators :@spec, :name, :extendable?, :is_gas?, :simple?

      # def name
      #   @original_name
      # end

  #     %w(incoherent unfixed).each do |state|
  #       define_method(state) do |atom_keyname|
  #         if @spec[atom_keyname]
  #           same_state = @options.find do |akn, st|
  #             akn == atom_keyname && st == state.to_sym
  #           end
  #           if same_state
  #             syntax_error('.atom_already_has_state',
  #               spec: @original_name, atom: atom_keyname, state: state)
  #           end

  #           @options << [atom_keyname, state.to_sym]
  #         end
  #       end
  #     end

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

      # Exchange current base spec to extended base spec
      def extend!
        external_bonds_after_extend unless @extended_spec
        @external_bonds_after_extend = nil
        @spec = @extended_spec
      end

      # Selects atoms that have changed compared to the other similar spec
      # @param [SpecificSpec] other another spec which similar as it
      # @return [Array] the array of changed atoms
      def changed_atoms(other_similar)
        actives, other_actives = only_actives, other_similar.only_actives

        atoms = actives.each_with_object([]) do |(keyname, atom), acc|
          other_atom = other_actives.delete(keyname)
          if !other_atom || atom.actives != other_atom.actives
            acc << atom
          end
        end

        atoms + other_actives.map { |keyname, _| @spec.atom(keyname) }
      end

  #     def visit(visitor)
  #       @spec.visit(visitor)
  #       visitor.accept_specific_spec(self)
  #     end

  #     def same?(other)
  #       other == self ||
  #         ((self.is_a?(other.class) || other.is_a?(self.class)) &&
  #           @spec == other.spec &&
  #             (@options == other.options || (!@options.empty? &&
  #               @options.size == other.options.size && correspond?(other))))
  #     end

  #     def organize_dependencies(similar_specs)
  #       similar_specs = similar_specs.reject do |s|
  #         s.options.size >= @options.size
  #       end
  #       similar_specs = similar_specs.sort do |a, b|
  #         b.options.size <=> a.options.size
  #       end

  #       max_opts_size = -1
  #       @dependent_from = similar_specs.select do |ss|
  #         max_opts_size <= ss.options.size &&
  #           ((active? && ss.active?) || !(active? || ss.active?)) &&
  #           ss.options.all? { |option| @options.include?(option) } &&
  #           (max_opts_size = ss.options.size)
  #       end
  #     end

  #     def dependent_from
  #       @dependent_from && @dependent_from.first
  #     end

  #     def active?
  #       active_bonds_num > 0
  #     end

  #     def has_atom?(atom)
  #       (Atom.is_hydrogen?(atom) && @spec.external_bonds > 0) ||
  #         @spec.links.keys.find { |spec_atom| spec_atom.same?(atom) }
  #     end

  #     def look_around(atom_map)
  #       return if is_gas?

  #       # TODO: need to check unfixing

  #       atom_map.each do |specs, corrs|
  #         next unless specs.any? { |spec| spec == self }

  #         source, _ = specs
  #         xs = self == source ? [0, 1] : [1, 0]
  #         corrs.each do |mirror|
  #           atoms_with_links = specs.zip(mirror).map do |specific_spec, atom|
  #             [specific_spec, specific_spec[atom], specific_spec.bonds_of(atom)]
  #           end

  #           _, own, incedent_bonds = atoms_with_links[xs.first]
  #           other, foreign, _ = atoms_with_links[xs.last]

  #           diff = own.diff(foreign)
  #           is_osa = own.is_a?(SpecificAtom)
  #           keyname = @spec.keyname(is_osa ? own.atom : own)
  #           own = SpecificAtom.new(own) unless is_osa

  # # puts "???? #{name}[#{keyname}]: #{diff.inspect}" unless diff.empty?

  #           # TODO: if atom has not remain bonds - to clean up the incidence
  #           if own.incoherent?
  #             diff -= [:incoherent]
  #           elsif other.is_gas?
  #             diff << :incoherent
  #           end

  #           if own.unfixed? || incedent_bonds.size > 1
  #             diff -= [:unfixed]
  #           elsif incedent_bonds.size == 1 && !own.lattice
  #             diff << :unfixed
  #           end

  #           unless diff.empty?
  # # puts "++++ #{name}[#{keyname}]: #{diff.inspect}"
  #             diff.each { |d| @options << [keyname, d] }
  #             expire_caches!
  #           end
  #         end
  #       end
  #     end

      def to_s
        # @spec.to_s(@spec.atoms.merge(@specific_atoms), links)
        @spec.to_s
      end

    protected

      attr_reader :specific_atoms

      # Selects only active atoms
      # @return [Hash] the hash where active atoms presents as values
      def only_actives
        @specific_atoms.select { |_, atom| atom.actives > 0 }
      end

      # def [](atom)
      #   unless @atoms_to_specific_atoms
      #     @atoms_to_specific_atoms = {}
      #     each_specific_atom do |original_atom, specific_atom|
      #       @atoms_to_specific_atoms[original_atom] = specific_atom
      #     end
      #   end

      #   @atoms_to_specific_atoms[atom] || atom
      # end

      # def bonds_of(atom)
      #   links_with_specific_atoms[self.[](atom)].select do |_, link|
      #     link.class == Bond
      #   end
      # end

    private

      # Counts the sum of active bonds
      # @return [Integer] sum of active bonds
      def active_bonds_num
        @specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.actives }
      end

      # Returns original links of base spec but exchange correspond atoms to
      # specific atoms
      #
      # @return [Hash] the hash of all links between atoms
      def links
        @links ||= @spec.links_with_replace_by(@specific_atoms)
      end

      # def keynames_to_specific_atoms
      #   @keynames_to_specific_atoms ||=
      #     @options.each_with_object({}) do |(atom_keyname, value), hash|
      #       specific_atom = hash[atom_keyname] ||
      #         SpecificAtom.new(@spec[atom_keyname])

      #       case value
      #       when :incoherent then specific_atom.incoherent!
      #       when :unfixed then specific_atom.unfixed!
      #       when '*' then specific_atom.active!
      #       end

      #       hash[atom_keyname] = specific_atom
      #     end
      # end

      # def each_specific_atom(&block)
      #   keynames_to_specific_atoms.each do |atom_keyname, specific_atom|
      #     block[@spec[atom_keyname], specific_atom]
      #   end
      # end

      # def expire_caches!
      #   @atoms_to_specific_atoms = nil
      #   @keynames_to_specific_atoms = nil
      #   @links_with_specific_atoms = nil
      # end

      # def correspond?(other)
      #   HanserRecursiveAlgorithm.contain?(
      #     links_with_specific_atoms, other.links_with_specific_atoms)
      # end
    end

  end
end
