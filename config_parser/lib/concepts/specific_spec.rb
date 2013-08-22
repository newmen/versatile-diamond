module VersatileDiamond
  module Concepts

    # Instance of it class represents usual specific spec that is most commonly
    # used in reactions
    class SpecificSpec
      extend Forwardable

      attr_reader :spec

      # Initialize specific spec instalce. Checks specified atom for correct
      # valence value
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

      # Makes a copy of other specific spec by dup each specific atom from it
      # @param [SpecificSpec] other the duplicating spec
      def initialize_copy(other)
        @spec = other.spec
        @specific_atoms = Hash[other.specific_atoms.map { |k, a| [k, a.dup] }]
      end

      def_delegators :@spec, :name, :extendable?, :is_gas?, :simple?

      # Builds the full name of specific spec (with specificied atom info)
      # @return [String] the full name of specific spec
      def full_name
        args = @specific_atoms.reduce([]) do |arr, (keyname, atom)|
          arr << "#{keyname}: #{'*' * atom.actives}" if atom.actives > 0
          unless atom.relevants.empty?
            arr += atom.relevants.map do |state|
              "#{keyname}: #{state.to_s[0]}"
            end
          end
          arr
        end
        args = args.empty? ? '' : "(#{args.join(', ')})"
        "#{name}#{args}"
      end

      # Gets corresponding atom, because it can be specific atom
      # @param [Symbol] keyname the atom keyname
      # @return [Atom | SpecificAtom] the corresponding atom
      def atom(keyname)
        @specific_atoms[keyname] || @spec.atom(keyname)
      end

      %w(incoherent unfixed).each do |state|
        # Defines #{state} method which change a state of atom selected by
        # keyname
        #
        # @param [Symbol] atom_keyname the keyname of selecting atom
        # @raise [Errors::SyntaxError] if atom already has setuping state
        define_method("#{state}!") do |atom_keyname|
          atom = @specific_atoms[atom_keyname]
          unless atom
            atom = SpecificAtom.new(@spec.atom(atom_keyname))
            @specific_atoms[atom_keyname] = atom
          end
          atom.send("#{state}!")
        end
      end

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

      # Looks around by atom mapping result and changes incoherent or unfixed
      # property of internal atom if need
      #
      # @param [Array] atom_map the atom mapping result from reaction
      def look_around!(atom_map)
        return if is_gas?

        # TODO: need to check unfixing (??)

        atom_map.each do |specs, corrs|
          next unless specs.any? { |spec| spec == self }

          source, _ = specs
          xs = self == source ? [0, 1] : [1, 0]
          corrs.each do |mirror|
            atoms_with_links = specs.zip(mirror).map do |specific_spec, atom|
              [specific_spec, atom, specific_spec.bonds_of(atom).size]
            end

            _, own, incedent_bonds = atoms_with_links[xs.first]
            other, foreign, _ = atoms_with_links[xs.last]

            unless own.is_a?(SpecificAtom)
              keyname = @spec.keyname(own) # uses if differences exists
              own = SpecificAtom.new(own)
            end
            diff = own.diff(foreign)

            # TODO: if atom has not remain bonds then not set incoherent status (rspec it!)
            own.incoherent! if !own.incoherent? && (other.is_gas? ||
              (diff.include?(:incoherent) && own.valence > incedent_bonds))

            own.unfixed! if !own.unfixed? && incedent_bonds == 1 &&
              (other.is_gas? || (diff.include?(:unfixed) && !own.lattice))

            # store own specific atom if atom was a simple atom
            if keyname && (own.actives > 0 || !own.relevants.empty?)
              @specific_atoms[keyname] = own
              @links = nil
            end
          end
        end
      end

      # Gets parent specific spec
      # @return [SpecificSpec] the parten specific spec or nil
      def dependent_from
        @dependent_from
      end

      # Organize dependencies from another similar species. Dependencies set if
      # similar spec has less specific atoms and existed specific atoms is same
      # in both specs. Moreover, activated atoms have a greater advantage.
      #
      # @param [Array] similar_specs the array of specs where each spec has
      #   same basic spec
      def organize_dependencies(similar_specs)
        similar_specs = similar_specs.reject do |s|
          s == self || s.specific_atoms.size > @specific_atoms.size
        end
        similar_specs = similar_specs.sort do |a, b|
          if a.specific_atoms.size == b.specific_atoms.size
            b.active_bonds_num <=> a.active_bonds_num
          else
            b.specific_atoms.size <=> a.specific_atoms.size
          end
        end

        @dependent_from = similar_specs.find do |ss|
          ss.active_bonds_num <= active_bonds_num &&
            ss.specific_atoms.all? do |keyname, atom|
              a = @specific_atoms[keyname]
              a && atom.actives <= a.actives &&
                (atom.relevants - a.relevants).empty?
            end
        end
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

  #     def active?
  #       active_bonds_num > 0
  #     end

  #     def has_atom?(atom)
  #       (Atom.is_hydrogen?(atom) && @spec.external_bonds > 0) ||
  #         @spec.links.keys.find { |spec_atom| spec_atom.same?(atom) }
  #     end

      def to_s
        # @spec.to_s(@spec.atoms.merge(@specific_atoms), links)
        @spec.to_s
      end

      def inspect
        full_name
      end

    protected

      attr_reader :specific_atoms

      # Selects only active atoms
      # @return [Hash] the hash where active atoms presents as values
      def only_actives
        @specific_atoms.select { |_, atom| atom.actives > 0 }
      end

      # Counts the sum of active bonds
      # @return [Integer] sum of active bonds
      def active_bonds_num
        only_actives.reduce(0) { |acc, (_, atom)| acc + atom.actives }
      end

      # Selects bonds for passed atom
      # @param [Atom] atom the atom for which bonds will be selected
      # @return [Array] the array of bonds incedent to an atom
      def bonds_of(atom)
        ls = links[atom] || links[atom(@spec.keyname(atom))]
        ls.select { |_, link| link.class == Bond }.map(&:last)
      end

    private

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
