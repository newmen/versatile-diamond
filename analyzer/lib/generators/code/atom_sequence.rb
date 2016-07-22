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
          usages = atoms.map { |a| -major_bonds_num(a) }
          props = atoms.map(&method(:atom_properties_for))
          keynames = atoms.map(&spec.spec.public_method(:keyname))
          triple = usages.zip(props, keynames)
          sorteds = triple.zip(atoms).sort_by(&:first).map(&:last)
          amorphs = sorteds.reject(&:lattice)
          surfaces = sorteds.select(&:lattice)
          amorph_before ? amorphs + surfaces : surfaces + amorphs
        end

        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom which bond relations will be counted
        # @return [Integer] the number of exist bond relations
        def major_bonds_num(atom)
          spec.spec.links[atom].map(&:last).select(&:exist?).select(&:bond?).size
        end

        # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom from which the atom properties will be combined
        # @return [Organizers::AtomProperties]
        def atom_properties_for(atom)
          Organizers::AtomProperties.new(spec, atom)
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
