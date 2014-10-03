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
          return @_original_sequence if @_original_sequence

          @_original_sequence =
            if spec.rest
              dynamic_rest = spec
              spec.sorted_parents.reduce(addition_atoms) do |acc, parent|
                mirror = dynamic_rest.mirror_to(parent).invert
                dynamic_rest -= parent

                acc + get(parent).original.map { |atom| mirror[atom] }
              end
            else
              sort_atoms(atoms)
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
          return @_addition_atoms if @_addition_atoms

          rest = spec.rest
          @_addition_atoms =
            if rest
              adds = spec.anchors.reject { |atom| rest.twin(atom) }
              sort_atoms(adds)
            else
              []
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

      protected

        attr_reader :spec, :cacher

        # Reverse sorts the atoms by number of their relations
        # @param [Array] atoms the array of sorting atoms
        # @option [Boolean] :amorph_before if true then latticed atoms will be at end
        #   in returned sequence
        # @return [Array] sorted array of atoms
        def sort_atoms(atoms, amorph_before: true)
          atoms.sort do |a, b|
            # a < b => -1
            # a == b => 0
            # a > b => 1
            if a.lattice == b.lattice
              a_size, b_size = spec.spec.links[a].size, spec.spec.links[b].size
              a_size == b_size ?
                spec.links[a].size <=> spec.links[b].size :
                b_size <=> a_size
            elsif (amorph_before && !a.lattice && b.lattice) ||
                (!amorph_before && a.lattice && !b.lattice)
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
