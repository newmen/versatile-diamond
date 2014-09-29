module VersatileDiamond
  module Generators
    module Code

      # Provides logic for detecting necessary symmetric cpp classes
      class SymmetriesDetector
        include Modules::ListsComparer
        include SymmetryHelper

        # Initializes symmetries detector
        # @param [EngineCode] generator the general engine code generator
        # @param [Specie] specie cpp code generator
        def initialize(generator, specie)
          @generator = generator
          @specie = specie

          @symmetries = {}
          @self_insec = spec.non_term_children.empty? ? [{}] : intersec_with_itself
          @deep_parent_swappers = {}

          @_children_collected = false
          @_symmetries_collected = false
        end

        # Collects symmetric atoms by children of internal specie
        def collect_symmetries
          return if @_children_collected
          @_children_collected = true

          spec.non_term_children.each { |child| get(child).collect_symmetries }
          return unless spec.rest

          atoms_for_parents = Hash[spec.parents.map { |p| [p, []] }]
          anchors.each do |atom|
            spec.rest.all_twins(atom).each do |twin|
              spec.parents.each do |parent|
                if get(parent).atoms.include?(twin)
                  atoms_for_parents[parent] << twin
                end
              end
            end
          end

          atoms_for_parents.each do |parent, atoms|
            get(parent).add_symmetries_for(atoms)
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

      protected

        # Adds symmetric atoms pairs
        # @param [Array] atoms which symmetries will be stored if them exists
        def add_symmetries_for(atoms)
          overlaps_for(atoms).each do |overlap|
            next if @symmetries.keys.any? do |pairs|
              pairs.all?(&presented_in(overlap))
            end

            overlap.size == 1 && spec.parents.size == 1 &&
              (dps = deep_parents_swapper(overlap.to_a.first))

            if dps
              @symmetries[overlap] = dps.proxy(@specie.original)
            else
              store_symmetry(overlap)
            end
          end
        end

        # Gets a parent which depends from several parents and each atom of pair
        # belongs to different parent
        #
        # @param [Array] pair of atoms which will be checked
        # @return [AtomSequence] the parent sequence or nil
        def deep_parents_swapper(pair)
          ps = spec.parents.size
          if ps == 1
            parent = get(spec.parents.first)
            if parent.atoms.size == atoms.size
              return parent.deep_parents_swapper(twins_of(pair))
            end
          elsif ps > 1
            if pair.all? { |a| spec.rest.all_twins(a).size == 1 }
              twins = twins_of(pair)
              return store_symmetry(Hash[[pair]]) if twins.first == twins.last
            end
          end
          nil
        end

      private

        # Delegates getting cacher to general engine code generator
        # @return [DetectorsCacher] cacher which will be used for getting an other
        #   detector by dependent wrapped spec
        def cacher
          @generator.detectors_cacher
        end

        # Delegates getting dependent spec to specie code generator
        # @return [Organizers::DependentWrappedSpec] the original dependent spec
        def spec
          @specie.spec
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
          @self_insec.each.with_object([]) do |intersec, all_overlaps|
            overlap = {}
            is_present = presented_in(overlap)

            atoms.each do |atom|
              other_atom = intersec[atom]
              next if other_atom == atom || is_present[atom, other_atom]
              overlap[atom] = other_atom
            end

            next if overlap.empty?
            next if lists_are_identical?(overlap.flatten, atoms, &:==)
            next if all_overlaps.any? { |pairs| pairs.all?(&is_present) }

            all_overlaps << overlap
          end
        end

        # Gets the twins of pair of atoms
        # @param [Array] pair of atoms
        # @return [Array] the twins of passed atoms
        def twins_of(pair)
          pair.map { |a| spec.rest.twin(a) }
        end

        # Delegates getting atom index to specie atom sequence
        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which index will be got
        # @return [Integer] the index of atom
        def atom_index(atom)
          @specie.sequence.atom_index(atom)
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
          if spec.rest
            parentable_symmetric(pairs)
          else
            pairs.reduce(@specie.original) do |acc, indexes|
              AtomsSwappedSpecie.new(@generator, acc, *indexes)
            end
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
          sorted_parents.each_with_index do |parent, i|
            panum = parent.atoms_num
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