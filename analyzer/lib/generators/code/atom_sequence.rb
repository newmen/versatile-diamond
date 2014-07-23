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
          @_original_sequence = nil
        end

        # Makes original sequence of atoms which will be used for get an atom index
        # @return [Array] the original sequence of atoms of current specie
        def original
          return @_original_sequence if @_original_sequence

          @_original_sequence =
            if spec.rest
              twins = back_twins
              sorted_parents = spec.parents.sort_by { |p| -p.size }
              sorted_parents.reduce(addition_atoms) do |acc, parent|
                acc + get(parent).original.map do |parent_atom|
                  pair = twins.delete_one { |a, _| parent_atom == a }
                  own_atom = pair && pair.last
                  own_atom || parent_atom
                end
              end
            else
              sort_atoms(anchors)
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
          symmetric_atoms.map do |reverse_mirror|
            symc_atoms = reverse_mirror.keys
            indexes = symc_atoms.map(&method(:atom_index))

            binding.pry if reverse_mirror.size != 2
            raise 'Too small reverse mirror' if reverse_mirror.size < 2
            raise 'Too large reverse mirror' if reverse_mirror.size > 2

            klass =
              if symc_atoms.all? { |a| anchors.include?(a) }
                ParentsSwappedSpecie
              else
                AtomsSwappedSpecie
              end

            klass.new(generator, original_specie, *indexes)
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

        # Gets the array of twin pairs
        # @return [Array] the array of twin pairs
        def back_twins
          anchors.map { |atom| [spec.rest.twin(atom), atom] }
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
        # @param [AtomsSequence] child_seq the sequence of child specie
        # @param [Array] intersec the array of intersections with child specie
        # @return [Array] the array of filtered intersections
        def filter_intersections(child_seq, intersec)
          child_anchors = child_seq.anchors

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
          result = Set.new
          spec.non_term_children.each do |child|
            intersec = intersec_with(child)

            # intersec must be found in any case
            unless intersec.first.size == spec.links.size
              raise "Correct intersec wasn't found"
            end

            child_seq = get(child)
            filtered_intersec = filter_intersections(child_seq, intersec)
            next if filtered_intersec.size == 1

            # drops one intersec because it's already as original sequence
            major = filtered_intersec.shift
            invert_major = major.invert

            filtered_intersec.each do |insec|
              diff = insec.select { |from, to| major[from] != to }
              reverse_mirror = diff.map { |from, to| [from, invert_major[to]] }
              if reverse_mirror.any? { |a, b| a == b }
                raise 'Reverse mirror to same atom'
              end
              result << Hash[reverse_mirror]
            end
          end

          result.to_a
        end
      end

    end
  end
end
