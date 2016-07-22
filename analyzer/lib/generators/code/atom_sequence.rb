module VersatileDiamond
  module Generators
    module Code

      # Contain specie as sorted atom sequence
      class AtomSequence
        include SymmetryHelper

        # Makes sequence from some specie
        # @param [SequenceCacher] cacher will be used for get anoter atom sequence
        #   instances
        # @param [Organizers::DependentSpec] spec the atom sequence for which will
        #   be calculated
        def initialize(cacher, spec)
          @cacher = cacher
          @spec = spec

          @_original_sequence, @_short_sequence, @_major_atoms, @_addition_atoms = nil
        end

        # Makes original sequence of atoms which will be used for get an atom index
        # @return [Array] the original sequence of atoms of current specie
        # TODO: should be protected
        def original
          @_original_sequence ||=
            if spec.source?
              sort_atoms(atoms)
            else
              sorted_parents.reduce(addition_atoms) do |acc, parent|
                acc + get(parent.original).original.map do |atom|
                  parent.atom_by(atom)
                end
              end
            end
        end

        # Gets short sequence of anchors
        # @return [Array] the short sequence of different atoms
        def short
          @_short_sequence ||= sort_atoms(spec.anchors, amorph_before: false)
        end

        # Gets a atoms list of short sequence without addition atoms
        # @return [Array] the array of major anchor atoms
        def major_atoms
          @_major_atoms ||= short - addition_atoms
        end

        # Detects additional atoms which are not presented in parent species
        # @return [Array] the array of additional atoms
        def addition_atoms
          @_addition_atoms ||=
            if spec.source?
              []
            else
              sort_atoms(spec.anchors.select { |a| spec.twins_of(a).empty? })
            end
        end

        # Counts delta between atoms num of current specie and sum of atoms num of
        # all parents
        #
        # @return [Integer] the delta between atoms nums
        def delta
          addition_atoms.size
        end

        # Gets an index of some atom
        # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which index will be got from original sequence
        # @return [Integer] the index of atom in original sequence
        # TODO: rspec
        def atom_index(atom)
          original.index(atom)
        end

        def to_s
          concept = spec.spec
          inner_str = original.map { |atom| ":#{concept.keyname(atom)}" }.join(' ')
          "(#{inner_str})"
        end

        def inspect
          to_s
        end

      private

        attr_reader :spec, :cacher

        # Reverse sorts the atoms by number of their relations
        # @param [Array] atoms the array of sorting atoms
        # @option [Boolean] :amorph_before if true then latticed atoms will be at end
        #   in returned sequence
        # @return [Array] sorted array of atoms
        def sort_atoms(atoms, amorph_before: true)
          atoms.sort do |*as|
            a, b = as
            if as.map(&:lattice).uniq.size > 1
              amorph_to_begin = amorph_before && !a.lattice && b.lattice
              crystal_to_begin = !amorph_before && a.lattice && !b.lattice
              amorph_to_begin || crystal_to_begin ? -1 : 1
            elsif as.map(&:specific?).uniq.size > 1
              a.specific? && !b.specific? ? -1 : 1
            elsif as.map(&:reference?).uniq.size > 1
              !a.reference? && b.reference? ? -1 : 1
            else
              order_similar(as, amorph_before: amorph_before)
            end
          end
        end

        # @param [Array] atoms the pair of sorting atoms
        # @return [Integer] the result of comparation
        def order_similar(atoms, amorph_before: true)
          ap, bp = atoms.map(&method(:atom_properties_for))
          if ap == bp
            ak, bk = atoms.map(&method(:keyname_for))
            ak <=> bk
          elsif ap.lattice && bp.lattice
            bp <=> ap
          else
            cmp = (ap <=> bp)
            amorph_before ? cmp : -cmp
          end
        end

        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom from which the atom properties will be combined
        # @return [Organizers::AtomProperties]
        def atom_properties_for(atom)
          Organizers::AtomProperties.new(spec, atom)
        end

        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom from which the keyname will be resolved
        # @return [Symbol]
        def keyname_for(atom)
          spec.spec.keyname(atom)
        end

        # @return [Array]
        def sorted_parents
          spec.parents.sort do |*parents|
            a, b = parents
            cmp = (a <=> b)
            if cmp == 0
              seq1, seq2 = parents.map do |parent|
                parent_seq = get(parent.original).original
                self_seq = parent_seq.map(&parent.public_method(:atom_by))
                self_seq.map(&spec.spec.public_method(:keyname))
              end
              seq1 <=> seq2
            else
              cmp
            end
          end
        end
      end

    end
  end
end
