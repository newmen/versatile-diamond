module VersatileDiamond
  module Mcs

    # Contains reactants and mapping result (how change each atom of stuctures)
    class MappingResult

      attr_reader :source, :products, :reaction_type

      # Recombines passed mapping result to list where each item is two spec_atom
      # elements
      #
      # @return [Array] the immutable list of correspond pairs of spec_atom from both
      #   sides of reaction
      def self.rezip(result)
        result.flat_map do |specs_pair, atoms_zip|
          atoms_zip.map { |atoms_pair| specs_pair.zip(atoms_pair) }
        end
      end

      # Common data structure:
      # @result = {
      #   conformity: [
      #     [
      #       [spec1, spec2],
      #       [
      #         [atom12, atom11], [atom11, atom12], [...]
      #       ]
      #     ],
      #     [...]
      #   ],
      #   change: [...]
      # }
      #
      # Initialize a result by reactants and setups internal mirrors to links
      # @param [Array] source the array of source species
      # @param [Array] products the array of product species
      # @option [Hash] :result the value of result variable by default
      # @raise [AtomMapper::CannotMap] if number of source or products is wrong
      def initialize(source, proructs, result: { change: [], conformity: [] }, rv: nil)
        @source, @products = source, proructs
        @result = result
        @reverse = rv

        size_wo_simple = -> specs { specs.reject(&:simple?).size }
        source_size_wo_simple = size_wo_simple[source]
        products_size_wo_simple = size_wo_simple[products]

        @reaction_type =
          if source_size_wo_simple == products_size_wo_simple
            :exchange
          elsif products_size_wo_simple == 1
            :association
          elsif source_size_wo_simple == 1
            :dissociation
          else
            raise AtomMapper::CannotMap, 'Wrong number of products and sources'
          end
      end

      # Gets atom mapping result only for changed atoms
      # @return [Array] the array which is atom mapping result only for changes
      #   atoms
      def changes
        @result[:change]
      end

      # Gets full atom mapping result for all atoms
      # @return [Array] the array which is atom mapping result for all atoms
      # TODO: must be private
      def full
        @result[:conformity]
      end

      # Collects atoms of passed spec which used in changes
      # @return [Array] the array of using atoms
      def used_atoms_of(spec)
        changes.select { |(s, _), _| s == spec }.flat_map(&:last).map(&:first)
      end

      # Finds other side spec and their atom that corresponds to passed args
      # @param [SpecificSpec] spec the spec for which will be found other side
      #   specific spec
      # @param [Atom] atom the atom for wich will be found analog in found
      #   specific spec
      # @return [SpecificSpec, Atom] the array where first item is found
      #   specific spec and second item is correspond atom
      def other_side(spec, atom)
        quads = all_zipped_spec_atoms
        quads = quads.map { |quad| quad.rotate(1) } unless @source.include?(spec)
        Hash[quads][[spec, atom]]
      end

      # Adds correspond mapping result for :change and :conformity keys. Also
      # changes reactant for relevant states of their atoms
      #
      # @param [Array] specs the associating species
      # @param [Array] full_atoms all atoms for each associating spec
      # @param [Array] changed_atoms only changed atoms for associating spec
      def add(specs, full_atoms, changed_atoms)
        spec1, spec2 = specs
        atoms1, atoms2 = full_atoms
        changes1, _ = changed_atoms

        # Changes specific specs and they atoms if it need. After, the
        # relevant states of atoms must be set accordingly.
        changes_zip = []
        full_zip = atoms1.zip(atoms2).map do |atom1, atom2|
          a1 = setup_by_other(spec1, spec2, atom1, atom2)
          a2 = setup_by_other(spec2, spec1, atom2, atom1)
          pair = [a1, a2]

          changes_zip << pair if changes1.include?(atom1)
          pair
        end

        reordered_full = changes_zip + (full_zip - changes_zip)
        associate(:conformity, spec1, spec2, reordered_full)
        associate(:change, spec1, spec2, changes_zip)
      end

      # Reverse atom mapping result
      # @return [Array] reversed atom mapping result
      def reverse
        return @reverse if @reverse
        reversed_result = @result.map do |key, mapping|
          reversed_mapping = mapping.map do |specs, atoms|
            [specs.reverse, atoms.map(&:reverse)]
          end
          [key, reversed_mapping]
        end

        opts = { result: reversed_result.to_h, rv: self }
        @reverse = self.class.new(@products, @source, **opts)
      end

      # Duplicates atom mapping result with exchange of original specs to specs
      # from passed mirrors
      #
      # @param [Hash] mirrors the hash where keys is :source and :products and
      #   values is mirrors from old specs to new
      def duplicate(mirrors)
        source = @source.map { |spec| mirrors[:source][spec] }
        products = @products.map { |spec| mirrors[:products][spec] }

        exchanged_result = @result.map do |key, mapping|
          exchanged_mapping = mapping.map do |(s, p), atoms|
            ns, np = mirrors[:source][s], mirrors[:products][p]
            exchanged_atoms = atoms.map do |v, w|
              [ns.atom(s.keyname(v)), np.atom(p.keyname(w))]
            end
            [[ns, np], exchanged_atoms]
          end
          [key, exchanged_mapping]
        end

        self.class.new(source, products, result: Hash[exchanged_result])
      end

      # Swap source species in result. Drops atom mapping result for atoms
      # which is not belongs to new spec if it spec is reduced version of from
      #
      # @param [Symbol] target the type of swapping species
      # @param [SpecificSpec] from which spec will be deleted
      # @param [SpecificSpec] to which spec will be added
      # @option [Boolean] :reverse_too
      def swap(target, from, to, reverse_too: true)
        return if from.simple?

        mirror = SpeciesComparator.make_mirror(from, to)
        trg = instance_variable_get(:"@#{target}")
        trg.map! { |spec| spec == from ? to : spec }

        @result.each do |_, mapping|
          mapping.map! do |specs, atoms|
            if target == :source && from == specs.first
              changed_atoms = atoms.map { |f, s| [mirror[f], s] }
              [[to, specs.last], changed_atoms]
            elsif target == :products && from == specs.last
              changed_atoms = atoms.map { |f, s| [f, mirror[s]] }
              [[specs.first, to], changed_atoms]
            else
              [specs, atoms]
            end
          end
        end
      end

      # Swaps atoms in result
      # @param [SpecificSpec] spec the specific spec atom of which will be
      #   exchanged
      # @param [Atom] from the old atom
      # @param [Atom] to the new atom
      # @option [Boolean] :reverse_too
      # @todo must be protected but checking by test
      def swap_atom(spec, from, to, reverse_too: true)
        is_source = @source.include?(spec)

        @result.each do |_, mapping|
          mapping.each do |specs, atoms|
            next unless spec == (is_source ? specs.first : specs.last)

            atoms.each do |pair|
              index = is_source ? 0 : 1
              if from == pair[index]
                specs[index].swap_atom(from, to)
                pair[index] = to
              end
            end
          end
        end

        if @reverse && reverse_too
          @reverse.swap_atom(spec, from, to, reverse_too: false)
        end
      end

      # Applies relevant states form new atom instead old atom
      # @param [SpecificSpec] spec the spec for which excahnging will do
      # @param [Atom | SpecificAtom] old_atom the atom which will be replaced
      # @param [SpecificAtom] new_atom the atom from which relevant states will
      #   got
      def apply_relevants(spec, old_atom, new_atom)
        os_spec, os_old_atom = other_side(spec, old_atom)
        swap_atom(spec, old_atom, new_atom) if old_atom != new_atom

        os_new_atom = setup_by_other(os_spec, spec, os_old_atom, new_atom)
        swap_atom(os_spec, os_old_atom, os_new_atom) if os_new_atom != os_old_atom
      end

      # Gets single source complex spec and their changed atom
      # @raise [RuntimeError] if complex source spec or their atom not just one
      # @return [Concepts::SpecificSpec, Concepts::SpecificAtom] the single
      #   spec and their atom
      def complex_source_spec_and_atom
        raise 'Cannot select single complex source spec' if changes.size > 1
        specs, atoms = changes.first
        raise 'Cannot select single changed atom' if atoms.size > 1
        [specs.first, atoms.first.first]
      end

      # Finds positions between atoms of different source species and stores them to
      # passed reaction
      #
      # @param [Reaction] reaction the reaction for which position finds
      def find_positions_for(reaction)
        return if @source.one? || @source.size == @products.size

        main_spec, idx = @source.one? ? [@source.first, 0] : [@products.first, 1]

        all_zipped_spec_atoms.combination(2).each do |quads|
          main_pairs, small_pairs = quads.transpose.rotate(idx)
          main_atoms = main_pairs.map(&:last)
          next unless reaction.all_latticed?(*main_atoms)

          position = main_spec.position_between(*main_atoms)
          next unless position

          small_specs, small_atoms = small_pairs.transpose
          if reaction.all_latticed?(*small_atoms)
            next if small_specs.first == small_specs.last
            reaction.position_between(*small_pairs, position, check_possible: false)
          else
            deep_find_positions(reaction, main_spec, main_atoms, position)
          end
        end
      end

    private

      # Finds position relations by walking on crystal lattice from passed main atoms
      # and stores found positions to passed reaction
      #
      # @param [Reaction] reaction the reaction for which position finds
      # @param [SpecificSpec] main_spec the largest spec of reaction
      # @param [Array] main_atoms the atoms of passed main spec
      # @param [Position] position which will be added if correspond atoms will be
      #   found
      def deep_find_positions(reaction, main_spec, main_atoms, position)
        crystal = main_atoms.first.lattice.instance
        return unless crystal.flatten?(position)

        rel_groups = main_atoms.map do |a|
          not_flat_rels = main_spec.links[a].reject { |_, r| crystal.flatten?(r) }
          not_flat_rels.group_by { |_, r| r.params }
        end

        max_rel_groups = rel_groups.select do |groups|
          groups.select { |pr, group| crystal.relations_limit[pr] == group.size }
        end

        next_atoms = max_rel_groups.map.with_index do |groups, i|
          same_groups = groups.select do |pr, group|
            (other_group = rel_groups[i-1][pr]) && other_group.size == group.size
          end

          raise 'Wrong period of crystal lattice' if same_groups.size > 1
          same_groups.values.first.map(&:first)
        end

        return unless next_atoms.map(&:to_set).reduce(:&).empty?

        reordered_atoms = next_atoms.combination(2).flat_map do |scope1, scope2|
          variants_with_usages = scope1.permutation.map do |scope1_var|
            pairs = scope1_var.zip(scope2)
            positions = pairs.map { |pair| main_spec.position_between(*pair) }
            [scope1_var, positions.compact.size]
          end
          aligned_atoms = variants_with_usages.max_by(&:last).first
          [aligned_atoms, scope2].transpose
        end

        reordered_atoms.uniq.each do |diff_side_atoms|
          deep_small_pairs = diff_side_atoms.map { |a| other_side(main_spec, a) }
          deep_small_specs, deep_small_atoms = deep_small_pairs.transpose
          next if deep_small_specs.first == deep_small_specs.last

          unless reaction.all_latticed?(*deep_small_atoms)
            raise 'Incorrect atoms of reactants'
          end

          # TODO: check the fact that position changes to cross for not diamond lattice
          reaction.position_between(*deep_small_pairs, position.cross,
            check_possible: false)
        end
      end

      # Combines full atom mapping to list where each item is two spec_atom elements
      # @return [Array] the immutable list of correspond pairs of spec_atom from both
      #   sides of reaction
      def all_zipped_spec_atoms
        self.class.rezip(full)
      end

      # Associates two specs and their atoms between each other
      # @param [Symbol] key the key of result
      # @param [Concepts::SpecificSpec] spec1 the first spec
      # @param [Concepts::SpecificSpec] spec2 the second spec
      # @param [Array] atoms_zip zipped arrays of atoms from both specs
      def associate(key, spec1, spec2, atoms_zip)
        @result[key] << [[spec1, spec2], atoms_zip]
      end

      # Checks "own" atom for new relevant states from other spec
      # @param [Concepts::SpecificSpec] target the spec for which checks state
      #   of own atom, if state is changed then target changes too
      # @param [Concepts::SpecificSpec] other the spec with which foreign atom
      #   compares the own atom
      # @param [Concepts::Atom | Concepts::SpecificAtom] own the atom for which
      #   checks the relevant states
      # @param [Concepts::Atom | Concepts::SpecificAtom] foreign the atom with
      #   witch compares the own atom
      # @return [Concepts::SpecificAtom] changed or original own atom
      def setup_by_other(target, other, own, foreign)
        return own if target.gas?

        original_own = own
        own = SpecificAtom.new(own) unless own.specific?
        diff = own.diff(foreign)

        extb = target.external_bonds_for(original_own)
        if extb > 0
          own.incoherent! if !own.incoherent? && !own.unfixed? &&
                    (other.gas? || diff.include?(Incoherent.property) ||
                      (other.links[foreign] && other.external_bonds_for(foreign) == 0))
        elsif extb == 0
          own.not_incoherent! if own.incoherent?
        end

        own.unfixed! if !own.incoherent? && !own.unfixed? &&
          own.valence - target.external_bonds_for(original_own) == 1 &&
          ((other.gas? && !other.simple?) || diff.include?(Unfixed.property)) &&
          !own.lattice

        # return own specific atom if atom was a simple atom
        if own != original_own && !own.relevants.empty?
          keyname = target.keyname(original_own)

          # changing target through specific spec
          target.describe_atom(keyname, own)
          own
        else
          original_own
        end
      end
    end

  end
end
