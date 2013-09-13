module VersatileDiamond
  module Mcs

    # Contains reactants and mapping result (how change each atom of stuctures)
    class MappingResult

      attr_reader :source, :products, :links_and_reactants

      # Initialize a result by reactants and setups internal mirrors to links
      # @param [Array] source the array of source species
      # @param [Array] products the array of product species
      # @option [Hash] :result the value of result variable by default
      def initialize(source, proructs, result: { change: [], conformity: [] })
        @source, @products = source, proructs
        @result = result
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

      # Adds correspond mapping result for :change and :conformity keys
      # @param [Array] specs the associating species
      # @param [Array] full_atoms all atoms for each associating spec
      # @param [Array] changed_atoms only changed atoms for associating spec
      def add(specs, full_atoms, changed_atoms)
        spec1, spec2 = specs
        atoms1, atoms2 = full_atoms
        changes1, changes2 = changed_atoms

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

        associate(:conformity, spec1, spec2, full_zip)
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

      # Swap source species in result
      # @param [SpecificSpec] from which spec will be deleted
      # @param [SpecificSpec] to which spec will be added
      def swap_source(from, to)
        @source.map! { |spec| spec == from ? to : spec }
        @result.each do |_, mapping|
          mapping.map! do |specs, atoms|
            spec = specs.first
            if spec == from
              changed_atoms = atoms.map do |f, s|
                [to.atom(from.keyname(f)), s]
              end
              [[to, specs.last], changed_atoms]
            else
              [specs, atoms]
            end
          end
        end
      end

      # Gets single source complex spec and their changed atom
      # @return [Concepts::SpecificSpec, Concepts::SpecificAtom] the single
      #   spec and their atom
      def complex_source_spec_and_atom
        raise 'Cannot select single complex source spec' if changes.size > 1
        specs, atoms = changes.first
        raise 'Cannot select single changed atom' if atoms.size > 1
        [specs.first, atoms.first.first]
      end

      # Finds positions between atoms of different source species
      # @return [Array] the array of positions between reactants atoms
      def find_positions
        return [] if @source.size == 1 || @source.size == @products.size

        positions = []
        result_dup = full.dup
        begin
          first = result_dup.shift

        end while result_dup.size > 1
        positions
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
        return own if target.is_gas?
        original_own = own

        own = SpecificAtom.new(own) unless own.is_a?(SpecificAtom)
        diff = own.diff(foreign)

        # TODO: if atom has not remain bonds then not set incoherent status (rspec it!)
        own.incoherent! if !own.incoherent? && (other.is_gas? ||
          (diff.include?(:incoherent) &&
            target.external_bonds_for(original_own) > 0))

        own.unfixed! if !own.unfixed? &&
          own.valence - target.external_bonds_for(original_own) == 1 &&
          (other.is_gas? || (diff.include?(:unfixed) && !own.lattice))

        # return own specific atom if atom was a simple atom
        if own != original_own && !own.relevants.empty?
          keyname = target.keyname(original_own)
          target.describe_atom(keyname, own) # changing target!
          own
        else
          original_own
        end
      end
    end

  end
end
