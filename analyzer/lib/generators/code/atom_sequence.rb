module VersatileDiamond
  module Generators
    module Code

      # Contain specie as sorted atom sequence
      class AtomSequence

        # Makes sequence from some specie
        # @param [Specie] specie code generator the atom sequence for which will be
        #   calculated
        def initialize(specie)
          @specie = specie
        end

        # Finds self symmetrics by children species which are uses symmetric atoms of
        # current specie. Should be called from generator after than all specie class
        # renderers will be created.
        def find_symmetrics(chidlren)
          symmetrics = []
          children.each do |child|
            intersec = intersec_with(child)
binding.pry

            # intersec must be found in any case
            unless intersec.first.size == spec_links.size
              raise "Correct intersec wasn't found"
            end

            filtered_intersec = child.filter_intersections(intersec)
            next if filtered_intersec.size == 1

            binding.pry if spec.name == :bridge

            major_intersec = filtered_intersec.shift
            reset_all_props(major_intersec.map(&:first))

            # TODO: remakes to atom properties
            filtered_intersec.each do |insec|
              proped_sec = insec.map { |pair| propertize(pair, [spec, child.spec]) }
              symmetrics << proped_sec unless @symmetrics.include?(proped_sec)
            end
          end

          symmetrics
        end

        # Is symmetric specie? If children species uses same as own atom and it atom
        # has symmetric analogy
        #
        # @return [Boolean] is symmetric specie or not
        def symmetric?
          !@symmetrics.empty?
        end

# FROM HERE <<<<<<<<<<<<<<<<<<<<<<<<<

        # Detects additional atoms which are not presented in parent species
        # @return [Array] the array of additional atoms
        def addition_atoms
          adds = parents.reduce(@all_props) do |acc, parent|
            acc - parent.atoms_sequence
          end
          sort_atoms(adds)
        end

        # Makes general sequence of atoms which will be used for get an atom index
        # @return [Array] the general sequence of atoms of current specie
        def atoms_sequence
          @_atoms_sequence ||=
            if parents.size == 0
              sort_atoms(@all_props)
            else
              result = atoms_delta > 0 ? addition_atoms : []
              parents.reduce(result) { |acc, parent| acc + parent.atoms_sequence }
            end
        end

        # Gets an index of some atom
        # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which index will be got from general sequence
        # @return [Integer] the index of atom in general sequence
        def atom_index(atom)
          atoms_sequence.index(atom)
        end

# TO HERE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

      protected

        # Filters intersections with parent specie. Checks that anchors points to
        # different atoms of parent specie.
        #
        # @param [Array] intersec the array of intersections with parent specie
        # @return [Array] the array of filtered intersections
        def filter_intersections(intersec)
          result = []
          collector = Set.new # stores unique pairs of anchors from intersec
          intersec.each do |insec|
            mirror = insec.invert
            new_collection = Set.new

            anchors.each do |atom|
              parent_atom = mirror[atom]
              unless new_collection.include?(parent_atom)
                new_collection << [atom, parent_atom]
              end
            end

            unless collector.include?(new_collection)
              collector << new_collection
              result << insec
            end
          end
          result
        end

        # Resets the internal atom sequence
        def reset_sequence
          @_atoms_sequence = nil
          children.each { |c| c.reset_sequence }
        end

      private

        # Remakes the links and exchanges all atoms to correspond atoms
        # @param [Organizers::DependentBaseSpec | Organizers::DependentSpecificSpec |
        #   Organizers::SpecResidual] spec links of which will be atomertized
        # @return [Hash] the links between atoms
        def atomertize_links(spec)
          result = spec.links.map do |atom, list|
            atom = Organizers::AtomProperties.new(spec, atom)
            updated_list = list.map do |a, relation|
              [spec.links[a] || make_cap, relation]
            end
            [atom, updated_list]
          end
          Hash[result]
        end

        # Finds intersec with some another specie
        # @param [Specie] child of current specie with which intersec will be found
        # @return [Array] the array of all possible intersec
        def intersec_with(child)
          args = [self, child, { collaps_multi_bond: true }]
          insec = SpeciesComparator.intersec(*args) do |_, _, self_atom, child_atom|
            self_atom.contained_in?(child_atom)
          end
          binding.pry
          insec.map { |ins| Hash[ins.to_a] }
        end

        # Sets the atoms from passed list and drops the internal cache
        # @param [Array] atoms the list of all atoms where new anchors of specie
        #   renderer will be selected
        def reset_all_props(atoms)
          @all_props = propertize(atoms)
          reset_sequence
        end

        # Reverse sorts the atoms by number of their relations
        # @param [Array] atoms the array of sorting atoms
        # @return [Array] sorted array of atoms
        def sort_atoms(atoms)
          atoms.sort_by { |pr| -spec_links[pr].size }
        end

        # Counts delta between atoms num of current specie and sum of atoms num of
        # all parents
        #
        # @return [Integer] the delta between atoms nums
        def atoms_delta
          return @_atoms_delta if @_atoms_delta
          plss = parents.map(&:spec).map(&:links).map(&:size).reduce(:+) || 0
          @_atoms_delta = spec.links.size - plss
        end
      end

    end
  end
end
