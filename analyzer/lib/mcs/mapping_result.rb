module VersatileDiamond
  module Mcs

    # Contains reactants and mapping result (how change each atom of stuctures)
    class MappingResult

      attr_reader :source, :products, :reaction_type

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
      def initialize(source, proructs, result: { change: [], conformity: [] })
        @source, @products = source, proructs
        @result = result

        size_wo_simple = -> specs { specs.reject { |sp| sp.simple? }.size }
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

      # Finds other side spec and their atom that corresponds to passed args
      # @param [SpecificSpec] spec the spec for which will be found other side
      #   specific spec
      # @param [Atom] atom the atom for wich will be found analog in found
      #   specific spec
      # @return [SpecificSpec, Atom] the array where first item is found
      #   specific spec and second item is correspond atom
      def other_side(spec, atom)
        is_source = @source.include?(spec)

        specs, atoms = nil
        full.each do |specs_pair, atoms_zip|
          next unless specs_pair.include?(spec)

          atoms = atoms_zip.find do |atom1, atom2|
            (is_source && atom1 == atom) || (!is_source && atom2 == atom)
          end
          next unless atoms

          specs = specs_pair
          break
        end

        return nil unless specs && atoms

        reverse_index = is_source ? 1 : 0
        [specs[reverse_index], atoms[reverse_index]]
      end

      # Adds correspond mapping result for :change and :conformity keys. Also
      # changes reactant for relevant states of ther atoms
      #
      # @param [Array] specs the associating species
      # @param [Array] full_atoms all atoms for each associating spec
      # @param [Array] changed_atoms only changed atoms for associating spec
      def add(specs, full_atoms, changed_atoms)
        spec1, spec2 = specs
        atoms1, atoms2 = full_atoms
        changes1, _ = changed_atoms

        # Changes specifics specs and they atoms if it need. After, the
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
        reversed_result = Hash[@result.map do |key, mapping|
          reversed_mapping = mapping.map do |specs, atoms|
            [specs.reverse, atoms.map { |pair| pair.reverse }]
          end
          [key, reversed_mapping]
        end]
        @reverse = self.class.new(@products, @source, result: reversed_result)
      end

      # Duplicates atom mapping result with exchange of original specs to specs
      # from passed mirrors
      #
      # @param [Hash] mirrors the hash where keys is :source and :products and
      #   values is mirrors from old specs to new
      def duplicate(mirrors)
        source = @source.map { |spec| mirrors[:source][spec] }
        products = @products.map { |spec| mirrors[:products][spec] }

        exchanged_result = Hash[@result.map do |key, mapping|
          exchanged_mapping = mapping.map do |(s, p), atoms|
            ns, np = mirrors[:source][s], mirrors[:products][p]
            exchanged_atoms = atoms.map do |v, w|
              [ns.atom(s.keyname(v)), np.atom(p.keyname(w))]
            end
            [[ns, np], exchanged_atoms]
          end
          [key, exchanged_mapping]
        end]

        self.class.new(source, products, result: exchanged_result)
      end

      # Swap source species in result. Drops atom mapping result for atoms
      # which is not belongs to new spec if it spec is reduced version of from
      #
      # @param [SpecificSpec] from which spec will be deleted
      # @param [SpecificSpec] to which spec will be added
      def swap_source(from, to)
        @source.map! { |spec| spec == from ? to : spec }
        @result.each do |_, mapping|
          mapping.map! do |specs, atoms|
            spec = specs.first
            if spec == from
              changed_atoms = atoms.select { |f, _| from.keyname(f) }.
                map { |f, s| [to.atom(from.keyname(f)), s] }
              [[to, specs.last], changed_atoms]
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
      # @todo must be protected but checking by test
      def swap_atom(spec, from, to)
        is_source = @source.include?(spec)

        @result.each do |_, mapping|
          mapping.each do |specs, atoms|
            next unless spec == (is_source ? specs.first : specs.last)

            atoms.each do |pair|
              atom_index = is_source ? 0 : 1
              next unless from == pair[atom_index]
              pair[atom_index] = to
            end
          end
        end

        @reverse.swap_atom(spec, from, to) if @reverse
      end

      # Applies relevant states form new atom instead old atom
      # @param [SpecificSpec] spec the spec for which excahnging will do
      # @param [Atom | SpecificAtom] old_atom the atom which will be replaced
      # @param [SpecificAtom] new_atom the atom from which relevant states will
      #   got
      def apply_relevants(spec, old_atom, new_atom)
        os = other_side(spec, old_atom) if old_atom != new_atom
        os = other_side(spec, new_atom) unless os
        os_spec, os_old_atom = os
        swap_atom(spec, old_atom, new_atom) if old_atom != new_atom

        os_old_atom = os_spec.atom(os_spec.keyname(os_old_atom))
        os_new_atom = setup_by_other(os_spec, spec, os_old_atom, new_atom)

        if os_new_atom != os_old_atom
          swap_atom(os_spec, os_old_atom, os_new_atom)
        end
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

      # Finds positions between atoms of different source species
      # @param [Reaction] reaction the reaction for which selected position
      # @return [Array] the array of positions between reactants atoms
      # TODO: rspec it directly
      def find_positions_for(reaction)
        return if @source.size == 1 || @source.size == @products.size

        main_spec, index = @source.size == 1 ?
          [@source.first, 0] : [@products.first, 1]
        small_index = (index + 1) % 2

        result_dup = full.dup
        # [
        #   [[spec1, spec2], [[atom1, atom2], [...]]],
        #   [[spec1, spec3], [[atom1, atom3], [...]]],
        #   [...]
        # ]
        begin
          (specs, atoms_zip) = result_dup.shift
          small_spec1 = specs[small_index]
          atoms_zip.each do |f, s|
            first_atom, small_atom1 = sort_atoms(index, f, s)

            result_dup.each do |next_specs, next_atoms_zip|
              small_spec2 = next_specs[small_index]
              next_atoms_zip.each do |nf, ns|
                second_atom, small_atom2 = sort_atoms(index, nf, ns)

                # TODO: could be realized more effectively if use associated
                # graph from many to one algorithm

                position =
                  main_spec.position_between(first_atom, second_atom)
                next unless position &&
                  reaction.all_latticed?(small_atom1, small_atom2)

                reaction.position_between(
                  [small_spec1, small_atom1],
                  [small_spec2, small_atom2],
                  position)
              end
            end
          end

        end while result_dup.size > 1
      end

    private

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
        own = SpecificAtom.new(own) unless own.is_a?(SpecificAtom)
        diff = own.diff(foreign)

        extb = target.external_bonds_for(original_own)
        if extb > 0
          own.incoherent! if !own.incoherent? &&
            (other.gas? || diff.include?(:incoherent))
        elsif extb == 0
          own.not_incoherent! if own.incoherent?
        end

        own.unfixed! if !own.unfixed? &&
          own.valence - target.external_bonds_for(original_own) == 1 &&
          ((other.gas? && !other.simple?) || diff.include?(:unfixed)) &&
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

      # Sorts atoms according to index
      # @param [Integer] index the begin index (0 or 1)
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @return [Atom, Atom] ordered atoms
      def sort_atoms(index, first, second)
        index == 0 ? [first, second] : [second, first]
      end
    end

  end
end
