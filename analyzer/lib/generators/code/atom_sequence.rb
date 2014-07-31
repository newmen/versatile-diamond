module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contain specie as sorted atom sequence
      class AtomSequence

        # Makes sequence from some specie
        # @param [SequenceCacher] cacher will be used for get anoter atom sequence
        #   instances
        # @param [Organizers::DependentSpec] spec the atom sequence for which will
        #   be calculated
        def initialize(cacher, spec)
          @cacher = cacher
          @spec = spec
          @_original_sequence, @_parents_sequence = nil
        end

        # Makes original sequence of atoms which will be used for get an atom index
        # @return [Array] the original sequence of atoms of current specie
        def original
          return @_original_sequence if @_original_sequence

          @_original_sequence =
            if spec.rest
              twins = back_twins
              parents_sequence.reduce(addition_atoms) do |acc, parent|
                acc + parent.original.map do |parent_atom|
                  pair = twins.delete_one { |a, _| parent_atom == a }
                  own_atom = pair && pair.last
                  own_atom || parent_atom
                end
              end
            else
              sort_atoms(atoms)
            end
        end

        # Gets short sequence of anchors
        # @return [Array] the short sequence of different atoms
        def short
          sort_atoms(anchors)
        end

        # Counts delta between atoms num of current specie and sum of atoms num of
        # all parents
        #
        # @return [Integer] the delta between atoms nums
        def delta
          addition_atoms.size
        end

        # Gets symmetric instances of some original code specie
        # @param [EngineCode] generator the general generator of engine code
        # @param [OriginalSpecie] original_specie for which symmetric species will be
        #   instanced
        # @return [Array] the array of symmetric instances
        def symmetrics(generator, original_specie)
          sym_atoms = filter_atom_mirrors(symmetric_atoms)
          adds_suffix = sym_atoms.size > 1

          sym_atoms.map.with_index do |twins_mirror, summ_suff|
            pairs = twins_mirror.map { |pair| pair.map(&method(:atom_index)) }

            symmetric =
              sort_indexes_pairs(pairs).reduce(original_specie) do |acc, indexes|
                if spec.rest
                  pa_indexes = indexes.map(&method(:parent_index))
                  parent_indexes, atom_indexes = pa_indexes.transpose

                  parents_eq = parent_indexes[0] == parent_indexes[1]
                  atoms_eq = atom_indexes[0] == atom_indexes[1]

                  if parents_eq || !atoms_eq
                    AtomsSwappedSpecie.new(generator, acc, *atom_indexes)
                  else
                    ParentsSwappedSpecie.new(generator, acc, *parent_indexes)
                  end
                else
                  AtomsSwappedSpecie.new(generator, acc, *indexes)
                end
              end

            symmetric.set_suffix(summ_suff + 1) if adds_suffix
            symmetric
          end
        end

        # Gets an index of some atom
        # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which index will be got from original sequence
        # @return [Integer] the index of atom in original sequence
        # TODO: rspec
        def atom_index(atom)
          original.index(atom)
        end

      protected

        # Gets anchors of internal specie
        # @return [Array] the array of anchor atoms
        def anchors
          spec.target.links.keys
        end

        # Gets the all atoms of internal specie
        # @return [Array] the array of atoms
        def atoms
          spec.links.keys
        end

      private

        attr_reader :spec, :cacher

        # Wraps dependent spec to atom sequence instance
        # @param [Organizers::DependentWrappedSpec] spec which will be wrapped
        # @return [AtomSequence] the instance with passed specie
        def get(spec)
          cacher.get(spec)
        end

        # Gets the array of twin pairs where each first elemeint is twin atom from
        # child specie and each second element is atom from current specie
        #
        # @return [Array] the array of twin pairs
        def back_twins
          anchors.map { |atom| [spec.rest.twin(atom), atom] }
        end

        # Gets sorted parents of target specie
        # @return [Array] the sorted array of parent seqeucnes
        def parents_sequence
          spec.parents.sort_by { |p| -p.relations_num }.map(&method(:get))
        end

        # Reverse sorts the atoms by number of their relations
        # @param [Array] atoms the array of sorting atoms
        # @return [Array] sorted array of atoms
        def sort_atoms(atoms)
          atoms.sort do |a, b|
            # a < b => -1
            # a == b => 0
            # a > b => 1
            if a.lattice && !b.lattice
              -1
            elsif b.lattice && !a.lattice
              1
            else
              a_size, b_size = spec.spec.links[a].size, spec.spec.links[b].size
              a_size == b_size ?
                spec.links[a].size <=> spec.links[b].size :
                b_size <=> a_size
            end
          end
        end

        # Detects additional atoms which are not presented in parent species
        # @return [Array] the array of additional atoms
        def addition_atoms
          rest = spec.rest
          if rest
            adds = anchors.reject { |atom| rest.twin(atom) }
            sort_atoms(adds)
          else
            []
          end
        end

        # Finds intersec with some another specie
        # @param [Organizers::DependentSpec] child of internal spec with which
        #   intersec will be found
        # @return [Array] the array of all possible intersec
        def intersec_with(child)
          args = [@spec, child, { collaps_multi_bond: true }]
          insec = SpeciesComparator.intersec(*args) do |_, _, self_atom, child_atom|
            self_prop = Organizers::AtomProperties.new(@spec, self_atom)
            child_prop = Organizers::AtomProperties.new(child, child_atom)
            self_prop.contained_in?(child_prop)
          end
          insec.map { |ins| Hash[ins.to_a] }
        end

        # Filters intersections with parent specie. Checks that anchors points to
        # different atoms of parent specie.
        #
        # @param [Array] child_anchors the list of atom anchors
        # @param [Array] intersec the array of intersections with child specie
        # @return [Array] the array of filtered intersections
        def filter_intersections(child_anchors, intersec)
          result = []
          collector = Set.new # stores unique pairs of anchors from intersec

          intersec.each do |insec|
            mirror = insec.invert
            new_collection = Set.new

            child_anchors.each do |atom|
              parent_atom = mirror[atom]
              new_collection << [parent_atom, atom]
            end

            unless collector.include?(new_collection)
              collector << new_collection
              result << insec
            end
          end

          result
        end

        # Finds symmetric atoms of internal specie by children of them
        def symmetric_atoms
          symmetric_child_candidates.each.with_object([]) do |child, result|
            intersec = intersec_with(child)

            # intersec must be found in any case
            unless intersec.first.size == spec.links.size
              raise "Correct intersec wasn't found"
            end

            child_anchors = get(child).anchors
            filtered_intersec = filter_intersections(child_anchors, intersec)
            next if filtered_intersec.size == 1

            # drops one intersec because it's already as original sequence
            major = filtered_intersec.shift
            invert_major = major.invert

            filtered_intersec.each do |insec|
              diff = insec.select do |from, to|
                major[from] != to && child_anchors.include?(to)
              end

              reverse_mirror = diff.map { |from, to| [from, invert_major[to]] }
              if reverse_mirror.any? { |a, b| a == b }
                raise 'Reverse mirror to same atom'
              end

              reverse_mirror = Hash[reverse_mirror]
              already_present = result.any? do |rh|
                rh == reverse_mirror || rh == reverse_mirror.invert
              end

              result << reverse_mirror unless already_present
            end
          end
        end

        # Gets the children which have dependency from internal specie only one time
        # @return [Array] the array of single dependent child species
        def symmetric_child_candidates
          surfspecs = spec.non_term_children
          groups = surfspecs.group_by(&:object_id)
          groups.select { |_, g| g.size == 1 }.map(&:last).map(&:last)
        end

        # Filters mirrors by select only biggest mirrors
        # @param [Array] mirrors the array of hashes of atoms mirror
        # @return [Array] filtered mirrors set
        def filter_atom_mirrors(mirrors)
          max_size = mirrors.map(&:size).max
          mirrors.select { |mirror| mirror.size == max_size }
        end

        # Finds parent index and atom index in it
        # @param [Integer] atom_index the index of atom in original sequence
        # @return [Array] two values where the first is parent index and second is
        #   atom index in it
        def parent_index(atom_index)
          pi = nil
          ai = atom_index - delta
          parents_sequence.each_with_index do |parent, parent_index|
            panum = parent.atoms.size
            if ai < panum
              pi = parent_index
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
          pairs.sort do |pair_of_pairs|
            pq = pair_of_pairs.map { |pair| pair.map(&method(:parent_index)) }
            a, b = pq.map { |p| p.map(&:first) }

            a_diff = a[0] == a[1]
            b_diff = b[0] == b[1]

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
