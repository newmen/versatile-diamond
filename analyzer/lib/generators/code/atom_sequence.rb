module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contain specie as sorted atom sequence
      class AtomSequence

        # Makes sequence from some specie
        # @param [Organizers::DependentSpec] spec the atom sequence for which will
        #   be calculated
        def initialize(spec)
          @spec = spec
        end

        # Makes original sequence of atoms which will be used for get an atom index
        # @return [Array] the original sequence of atoms of current specie
        def original
          rest = spec.rest
          if spec.rest
            back_twins = anchors.map { |atom| [rest.twin(atom), atom] }
            spec.parents.reduce(addition_atoms) do |acc, parent|
              acc + wrap(parent).original.map do |parent_atom|
                pair = back_twins.delete_one { |a, _| parent_atom == a }
                own_atom = pair && pair.last
                own_atom || parent_atom
              end
            end
          else
            sort_atoms(anchors)
          end
        end

        # Gets short sequence of atoms. The atoms belongs to spec residual
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

        # Finds symmetrics of internal specie by children of them
        def find_symmetrics
          symmetrics = Set.new
          spec.non_term_children.each do |child|
            intersec = intersec_with(child)

            # intersec must be found in any case
            unless intersec.first.size == @spec.links.size
              raise "Correct intersec wasn't found"
            end

            filtered_intersec = filter_intersections(child, intersec)
            next if filtered_intersec.size == 1

            major_intersec = filtered_intersec.shift
            reset_all_props(major_intersec.map(&:first))

            # TODO: remakes to atom properties
            filtered_intersec.each do |insec|
              proped_sec = insec.map { |pair| propertize(pair, [spec, child.spec]) }
              symmetrics << proped_sec
            end
          end

          symmetrics.to_a
        end

        # Gets an index of some atom
        # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
        #   atom for which index will be got from original sequence
        # @return [Integer] the index of atom in original sequence
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
        # @param [Organizers::DependentWrappedSpec] spec the anchors of which will be
        #   returned
        # @return [Array] the array of atoms
        def atoms
          spec.links.keys
        end

        # Resets the internal atom sequence
        def reset_sequence
          @_sequence = nil
          children.each { |c| c.reset_sequence }
        end

      private

        attr_reader :spec

        # Wraps dependent spec to atom sequence instance
        # @param [Organizers::DependentWrappedSpec] spec which will be wrapped
        # @return [AtomSequence] the instance with passed specie
        def wrap(spec)
          self.class.new(spec)
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
              spec.links[a].size <=> spec.links[b].size
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

        #
        def propertize_anchors(spec)
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
        # @param [Organizers::DependentWrappedSpec] child of internal specie
        # @param [Array] intersec the array of intersections with child specie
        # @return [Array] the array of filtered intersections
        def filter_intersections(child, intersec)
          result = []
          collector = Set.new # stores unique pairs of anchors from intersec
          intersec.each do |insec|
            mirror = insec.invert
            new_collection = Set.new

            anchors_of(child).each do |atom|
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

        # Sets the atoms from passed list and drops the internal cache
        # @param [Array] atoms the list of all atoms where new anchors of specie
        #   renderer will be selected
        def reset_all_props(atoms)
          @all_props = propertize(atoms)
          reset_sequence
        end
      end

    end
  end
end
