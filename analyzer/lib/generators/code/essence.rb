module VersatileDiamond
  module Generators
    module Code

      # Contain logic for clean dependent specie and get essence of specie graph
      class Essence
        extend Forwardable

        # Initizalize cleaner by specie class code generator
        # @param [Specie] specie from which pure essence will be gotten
        def initialize(specie)
          @specie = specie
          @_cut_links, @_grouped_graph = nil
        end

        # Gets a links of current specie without links of parent species
        # @return [Hash] the link between atoms without links of parent species
        # TODO: must be private
        def cut_links
          return @_cut_links if @_cut_links

          rest = spec.rest
          @_cut_links =
            if rest
              atoms = rest.links.keys
              clean_links = rest.clean_links.map do |atom, rels|
                [atom, rels.select { |a, _| atom != a && atoms.include?(a) }]
              end

              twins = atoms.map { |atom| rest.all_twins(atom) }
              atoms_to_twins = Hash[atoms.zip(twins)]

              result = spec.parents.reduce(clean_links) do |acc, parent|
                acc.map do |atom, rels|
                  parent_links = parent.clean_links
                  parent_atoms = atoms_to_twins[atom]
                  clean_rels = rels.reject do |a, r|
                    pas = atoms_to_twins[a]
                    !pas.empty? && parent_atoms.any? do |p|
                      ppls = parent_links[p]
                      ppls && ppls.any? { |q, y| r == y && pas.include?(q) }
                    end
                  end

                  [atom, clean_rels.uniq]
                end
              end
              Hash[result]
            else
              spec.clean_links
            end
        end

        # Gets the atoms of cut links graph which are grouped by available neighbours
        # which are available through flatten relations that belongs to some crystal
        # face
        #
        # @return [Array] the array of arrays where each group contain similar related
        #   atoms
        # TODO: must be private
        def face_grouped_anchors
          groups = cut_links.keys.group_by do |atom|
            Set.new(flatten_neighbours_for(atom) + [atom])
          end
          groups.values
        end

        # Provides undirected graph of algorithm without bonds duplications. Atoms of
        # original specie links graph are grouped there by flatten relations between
        # atoms of cut_links graph.
        #
        # @return [Hash] the hash of sparse graph where keys are arrays of atoms
        #   which have similar relations with neighbour atoms and values are wrapped
        #   to arrays other side "vertex" and relation to it vertex
        def grouped_graph
          return @_grouped_graph if @_grouped_graph

          flatten_groups, non_flatten_groups = split_grouped_atoms
          result = {}

          flatten_groups.each do |group|
            accurate_atom_groups_from(group).each do |atoms, nbrs|
              result[atoms] ||= []
              relation = spec.relation_between(atoms.first, nbrs.first)
              result[atoms] << [nbrs, relation.params]
            end
          end

          non_flatten_groups.each do |group|
            combine_similar_relations(group) do |atoms, nbrs_with_rel_param|
              result[atoms] ||= []
              result[atoms] << nbrs_with_rel_param if nbrs_with_rel_param
            end
          end

          @_grouped_graph = result
        end

      private

        def_delegator :@specie, :spec

        # Gets atoms that used in cut links graph
        # @return [Array] the atoms which using in cut links graph
        def cut_keys
          cut_links.keys
        end

        # Gets all flatten relations of passed atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which flatten relations will be gotten
        # @return [Array] the array of relations where each relation is array of two
        #   items, where first item is neighbour atom and second item is relation
        #   instance
        def flatten_relations_of(atom)
          flatten_rels = spec.clean_links[atom].select do |a, r|
            flatten_relation?(a, r) && cut_keys.include?(a)
          end
        end

        # Gets all non flatten relations of passed atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which non flatten relations will be gotten
        # @return [Array] the array of relations where each relation is array of two
        #   items, where first item is neighbour atom and second item is relation
        #   instance
        def non_flatten_relations_of(atom)
          cut_links[atom].reject { |a, r| flatten_relation?(a, r) }
        end

        # Gets all flatten neighbours of passed atom. Moreover, if an atom has a few
        # ways for getting neighbors in flat face, then selects the most optimal.
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which flatten relations will be returned
        # @return [Array] the array of neighbour atoms which available through flatten
        #   relation
        def flatten_neighbours_for(atom)
          flatten_nbrs = flatten_relations_of(atom).map(&:first)
          if flatten_nbrs.size > 1
            flatten_nbrs.reject { |a| alive_relation?(atom, a) }
          else
            flatten_nbrs
          end
        end

        # Checks that passed relation is flatten in crystal lattice when placed atom
        # @return [Boolean] is flatten relation or not
        def flatten_relation?(atom, relation)
          lattice = atom.lattice
          if lattice
            relation.relation? && lattice.instance.flatten?(relation)
          else
            false
          end
        end

        # Checks that cut links graph has relation between passed atoms
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   from is the first atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   to is the second atom
        # @return [Boolean] has relation or not
        def alive_relation?(from, to)
          has_relation_in?(cut_links, from, to)
        end

        # Checks that clean specie links graph has relation between passed atoms
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   from is the first atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   to is the second atom
        # @return [Boolean] has relation or not
        def has_relation?(from, to)
          has_relation_in?(spec.clean_links, from, to)
        end

        # Checks that relation is present between passed atoms in also passed links
        # @param [Hash] links where relation will be found or not
        # @return [Boolean] has relation or not
        def has_relation_in?(links, from, to)
          links[from].any? { |a, _| a == to }
        end

        # Checks that atom has flatten relation
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which relations will be checked
        # @return [Boolean] atom has flatten relation or not
        def has_flatten_relation?(atom)
          !flatten_relations_of(atom).empty?
        end

        # Checks that atom has non flatten relation
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which relations will be checked
        # @return [Boolean] atom has non flatten relation or not
        def has_non_flatten_relation?(atom)
          !non_flatten_relations_of(atom).empty?
        end

        # Verifies that all flatten relations which passed atom have is link it only
        # with atoms from the passed group
        #
        # @param [Array] group of similar atoms
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which relations will be checked
        # @return [Boolean] are flatten relations used only by group atoms or not
        def only_flatten_relations_in?(group, atom)
          rels = cut_links[atom].select { |a, r| flatten_relation?(a, r) }
          rels.all? { |a, _| group.include?(a) }
        end

        # Separates the grouped atoms into two categories: atoms with flatten relations
        # and atoms with non flatten relations
        #
        # @return [Array] the array with two items where each item is array. The first
        #   item is groups of atoms with flatten relations and the second item is
        #   groups of atoms with non flatten relations
        def split_grouped_atoms
          face_grouped_anchors.each_with_object([[], []]) do |group, acc|
            acc.first << group if group.any? do |atom|
              has_flatten_relation?(atom) && !only_flatten_relations_in?(group, atom)
            end

            acc.last << group if group.any? do |atom|
              dept_only_from_group = only_flatten_relations_in?(group, atom)
              dept_only_from_group || cut_links[atom].empty? ||
                (!dept_only_from_group && has_non_flatten_relation?(atom))
            end
          end
        end

        # Accumulates atom with their most optimal neighbours
        # @param [Array] atoms which environment in flatten crystal face will be
        #   checked
        # @return [Array] the array with two items where the first item is array of
        #   atoms from which has similar relations to neighbour atoms which placed as
        #   second item of array
        def accurate_atom_groups_from(atoms)
          cut_rels = atoms.map { |atom| cut_links[atom] }
          neighbours = cut_rels.map { |rels| rels.map(&:first) }

          accurate_groups_hash = {}
          atoms.zip(neighbours).each do |atom, nbrs|
            (neighbours - [nbrs]).each do |other_nbrs|
              other_nbrs.each do |other_nbr|
                nbrs.each do |nbr|
                  # if relation presented then it in any time is flatten, because
                  # value which passed to current method is gotten from flatten anchors
                  # group
                  next unless has_relation?(nbr, other_nbr)
                  key = Set[nbr, other_nbr]
                  accurate_groups_hash[key] ||= []
                  accurate_groups_hash[key] << [atom, nbr]
                end
              end
            end
          end

          accurate_groups_hash.values.map(&:transpose)
        end

        # Combines similar relations which could be available for each atom from the
        # passed group
        #
        # @param [Array] group of atoms each of which could combine similar relations
        #   and neighbour atoms
        # @yield [Array, Hash] iterates each case after getting relations for each
        #   atom from group; the first argument of block procedure is array of atoms,
        #   which was combined when method do, but every time it array contain just one
        #   item which is iterating atom; the second argument of block procedure is
        #   relation parameters for neighbour atoms array
        def combine_similar_relations(group, &block)
          group.each do |atom|
            key = [atom]
            rels = cut_links[atom]

            if rels.empty?
              block[key, nil]
            else
              groupable_rels = only_flatten_relations_in?(group, atom) ?
                rels : non_flatten_relations_of(atom)

              similar_rels_groups = groupable_rels.group_by do |a, r|
                [Organizers::AtomProperties.new(spec, a), r.params]
              end

              similar_rels_groups.values.each do |similar_rels|
                nbrs, relations = similar_rels.transpose
                block[key, [nbrs, relations.first.params]]
              end
            end
          end
        end
      end

    end
  end
end
