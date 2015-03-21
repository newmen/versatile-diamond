module VersatileDiamond
  module Generators
    module Code

      # Provides logic for detecting necessary symmetric cpp classes
      class SymmetriesDetector
        include Modules::ListsComparer
        include SymmetryHelper
        extend Forwardable

        # Initializes symmetries detector
        # @param [EngineCode] generator the general engine code generator
        # @param [Specie] specie cpp code generator
        def initialize(generator, specie)
          @generator = generator
          @specie = specie

          @symmetries = {}
          @self_insec = intersec_with_itself
          @deep_parent_swappers = {}

          @_children_collected = false
          @_symmetries_collected = false
        end

        # Collects symmetric atoms by children of internal specie
        def collect_symmetries
          return if @_children_collected
          @_children_collected = true

          spec.non_term_children.each { |child| get(child).collect_symmetries }

          distrib_twins_to_parents(spec.anchors).each do |parent, twins|
            get(parent).add_symmetries_for(twins)
          end

          (spec.reactions.reject(&:local?) + spec.theres).each do |dept_user|
            add_symmetries_for(dept_user.used_atoms_of(spec))
          end
        end

        # Gets symmetric instances of some original code specie
        # @return [Array] the array of symmetric instances
        def symmetry_classes
          return @symmetries.values if @_symmetries_collected
          @_symmetries_collected = true

          if @symmetries.size > 1
            @symmetries.values.each_with_index do |symmetric, index|
              symmetric.set_suffix(index + 1)
            end
          end

          @symmetries.values
        end

        # Gets the list of symmetric atoms thats is analog of passed atom
        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which list of symmetric atoms will be gotten
        # @return [Array] the list of symmetric atoms
        def symmetric_atoms(atom)
          paired = all_paired_atoms_with(atom)
          paired.reduce(paired) { |acc, a| acc + all_paired_atoms_with(a) }.to_a
        end

        # Checks that atom is a symmetric atom in internal specie
        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is symmetric atom in internal specie or not
        def symmetric_atom?(atom)
          !select_symmetric_keys_for(atom).empty?
        end

      protected

        # Adds symmetric atoms pairs
        # @param [Array] atoms which symmetries will be stored if them exists
        def add_symmetries_for(atoms)
          overlaps_for(atoms).each do |overlap|
            next if @symmetries.keys.any? do |pairs|
              pairs.size == overlap.size && pairs.all?(&presented_in(overlap))
            end

            dps =
              overlap.size == 1 && !spec.source? && !spec.complex? &&
              deep_parents_swapper(overlap.to_a.first)

            if dps
              @symmetries[overlap] = dps.proxy(@specie.original)
            else
              store_symmetry(overlap)
            end
          end
        end

        # Gets a parent which depends from several parents and each atom of passed pair
        # belongs to different parent
        #
        # @param [Array] pair of atoms which will be checked
        # @return [AtomSequence] the parent sequence or nil
        def deep_parents_swapper(pair)
          if spec.complex?
            if pair.all? { |a| spec.twins_num(a) == 1 }
              twins = twins_of(pair)
              return store_symmetry(Hash[[pair]]) if twins.first == twins.last
            end
          elsif !spec.source?
            parent = get(spec.parents.first.original)
            if parent.atoms.size == atoms.size
              return parent.deep_parents_swapper(twins_of(pair))
            end
          end
          nil
        end

      private

        def_delegator :@specie, :spec

        # Delegates getting cacher to general engine code generator
        # @return [DetectorsCacher] cacher which will be used for getting an other
        #   detector by dependent wrapped spec
        def cacher
          @generator.detectors_cacher
        end

        # Finds intersec with itself
        # @return [Array] the array of all possible intersec
        def intersec_with_itself
          args = [spec.spec, spec.spec, { collaps_multi_bond: true }]
          Mcs::SpeciesComparator.intersec(*args).map { |ins| Hash[ins.to_a] }
        end

        # Provides a condition for check some collection that it pairs is presented
        # in passed hash
        #
        # @param [Hash] hash in which checking will be
        # @return [Proc] the checking function
        def presented_in(hash)
          proc { |a, b| hash[a] == b || hash[b] == a }
        end

        # Gets all overlaps of atoms to internal specie atoms sequence
        # @param [Array] atoms which will be checked for existing symmetric pair
        # @return [Array] the array of all unique overlaps
        def overlaps_for(atoms)
          @self_insec.each_with_object([]) do |intersec, all_overlaps|
            overlap = {}
            check_lambda = presented_in(overlap)

            atoms.each do |atom|
              other_atom = intersec[atom]
              next if other_atom == atom || check_lambda[atom, other_atom]
              overlap[atom] = other_atom
            end

            next if overlap.empty?
            next if lists_are_identical?(overlap.flatten, atoms, &:==)
            next if all_overlaps.any? { |pairs| pairs.all?(&check_lambda) }

            all_overlaps << overlap
          end
        end

        # Gets the twins of pair of atoms
        # @param [Array] pair of atoms
        # @return [Array] the twins of passed atoms
        def twins_of(pair)
          pair.map { |a| spec.twins_of(a).first }
        end

        # Distributes twins to their parents
        # @param [Array] atoms for which parents ant their twins will be collected
        # @result [Hash] the hash where keys are parent specie and values are arrays
        #   of correspond twins
        def distrib_twins_to_parents(atoms)
          atoms.each_with_object({}) do |atom, result|
            spec.parents_with_twins_for(atom).each do |parent, twin|
              result[parent.original] ||= []
              result[parent.original] << twin
            end
          end
        end

        # Gets an unique anchors
        # @return [Array] the array of unique anchors
        def uniq_anchors
          anchors = spec.anchors
          anchor_users = @symmetries.keys.select do |hash|
            hash.flatten.any? { |a| anchors.include?(a) }
          end

          if anchor_users.empty?
            anchors
          else
            hashes_with_diff_kv = anchor_users.select do |hash|
              hash.all? do |k, v|
                a, b = aps_from(k, v)
                a != b
              end
            end
            uniq_atoms = hashes_with_diff_kv.flat_map(&:flatten).uniq
            anchors.select { |a| uniq_atoms.include?(a) }
          end
        end

        # Delegates getting atom index to specie atom sequence
        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which index will be got
        # @return [Integer] the index of atom
        def atom_index(atom)
          @specie.sequence.atom_index(atom)
        end

        # Selects all available pairs where passed atom is presented
        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom by which symmetric keys will be found
        # @return [Array] the list of symmetric atom pairs
        def select_symmetric_keys_for(atom)
          @symmetries.keys.select { |hash| hash.flatten.include?(atom) }
        end

        # Collects all paired atoms of passed atom from symmetric keys
        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom see at #symmetric_atoms same argument
        # @return [Set] the set of paired atoms
        def all_paired_atoms_with(atom)
          select_symmetric_keys_for(atom).each_with_object(Set.new) do |hash, acc|
            hash.each do |pair|
              pair.each { |a| acc << a } if pair.include?(atom)
            end
          end
        end

        # Stores symmetric empty class to internal hash of symmetric instances
        # @param [Array] atoms the hash of symmetric atoms
        # @return [EmptySpecie] the empty specie symmetric instance
        def store_symmetry(atoms)
          indexes = atoms.map { |pair| pair.map(&method(:atom_index)) }
          @symmetries[atoms] = combine_symmetric(indexes)
        end

        # Makes empty symmetric code generator instance
        # @param [Array] pairs of indexes of symmetric atoms
        # @return [EmptySpecie] the symmetric specie code generator
        def combine_symmetric(pairs)
          if spec.source?
            pairs.reduce(@specie.original) do |acc, indexes|
              AtomsSwappedSpecie.new(@generator, acc, *indexes)
            end
          else
            parentable_symmetric(pairs)
          end
        end

        # Makes empty symmetric code generator for case when current specie have
        # parent specie(s)
        #
        # @param [Array] pairs see at #combine_symmetric same argument
        # @return [EmptySpecie] the symmetric specie code generator
        def parentable_symmetric(pairs)
          # TODO: there could be more simple sorting (by used klass value)
          creation_values = sort_indexes_pairs(pairs).map do |indexes|
            pa_indexes = indexes.map(&method(:parent_atom_index))
            parent_indexes, atom_indexes = pa_indexes.transpose.map(&:sort)

            parents_eq = parent_indexes[0] == parent_indexes[1]
            atoms_eq = atom_indexes[0] == atom_indexes[1]

            if parents_eq || !atoms_eq
              [AtomsSwappedSpecie, atom_indexes]
            else
              [ParentsSwappedSpecie, parent_indexes]
            end
          end

          creation_values.uniq! # like a f@%k

          creation_values.reduce(@specie.original) do |acc, (klass, indexes)|
            klass.new(@generator, acc, *indexes)
          end
        end

        # Finds parent index and atom index in it
        # @param [Integer] index of atom in original sequence
        # @return [Array] two values where the first is parent index and second is
        #   atom index in it
        def parent_atom_index(index)
          pi = nil
          ai = index - @specie.sequence.delta
          spec.parents.sort.each_with_index do |parent, i|
            panum = parent.links.size
            if ai < panum
              pi = i
              break
            else
              ai -= panum
            end
          end
          [pi, ai]
        end

        # Sorts pairs of indexes. The first indexes is indexes that belongs to
        # different parents, and last indexes is indexes of atom of similar parents.
        #
        # @param [Array] pairs of atom indexes which will be sorted by correspond
        #   using parent sequences
        # @return [Array] the array of sorted pairs
        def sort_indexes_pairs(pairs)
          pairs.sort do |as, bs|
            pq = [as, bs].map { |pair| pair.map(&method(:parent_atom_index)) }
            pa, pb = pq.map { |p| p.map(&:first) }

            a_diff = pa[0] == pa[1]
            b_diff = pb[0] == pb[1]

            if a_diff == b_diff
              0
            elsif !a_diff && b_diff
              -1
            else
              1
            end
          end
        end
      end

    end
  end
end
