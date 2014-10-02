module VersatileDiamond
  module Generators
    module Code

      # Contain logic for clean dependent specie and get essence of specie graph
      class Essence
        include Modules::ListsComparer
        include TwinsHelper

        # Initizalize cleaner by specie class code generator
        # @param [Specie] specie from which pure essence will be gotten
        def initialize(specie)
          @spec = specie.spec
          @sequence = specie.sequence
          @essence = algorithm_graph

          @_cut_links = nil
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
              clear_links = rest.clean_links.map do |atom, rels|
                [atom, rels.select { |a, _| atom != a && atoms.include?(a) }]
              end

              twins = atoms.map { |atom| rest.all_twins(atom).dup }
              twins = Hash[atoms.zip(twins)]

              result = spec.parents.reduce(clear_links) do |acc, parent|
                acc.map do |atom, rels|
                  parent_links = parent.clean_links
                  parent_atoms = twins[atom]
                  clear_rels = rels.reject do |a, r|
                    pas = twins[a]
                    !pas.empty? && parent_atoms.any? do |p|
                      ppls = parent_links[p]
                      ppls && ppls.any? { |q, y| r == y && pas.include?(q) }
                    end
                  end

                  [atom, clear_rels.uniq]
                end
              end
              Hash[result]
            else
              spec.clean_links
            end
        end

        # Provides undirected algorithm graph without bonds duplications. Atoms of
        # original specie links graph are grouped there by flatten relations between
        # atoms of cut_links graph.
        #
        # @return [Hash] the hash of sparse graph where keys are arrays of atoms
        #   which have similar relations with neighbour atoms and values are wrapped
        #   to arrays other side "vertex" and relation to it vertex
        def raw_algorithm_graph
          flatten_groups, non_flatten_groups = split_grouped_atoms
          result = {}

          flatten_groups.each do |group|
            accurate_atom_groups_from(group).each do |atoms, nbrs|
              result[atoms] ||= []
              result[atoms] << [nbrs, relations_between(atoms, nbrs)]
            end
          end

          non_flatten_groups.each do |group|
            combine_similar_relations(group) do |atoms, nbrs_with_rels|
              result[atoms] ||= []
              result[atoms] << nbrs_with_rels if nbrs_with_rels
            end
          end

          result
        end

        # Gets an essence of wrapped dependent spec but without reverse relations if
        # related atoms is similar. The nearer to top of achchors sequence, have more
        # relations in essence.
        #
        # @param [Specie] specie for which pure essence will be gotten
        # @return [Hash] the links hash without reverse relations
        # @example
        #   [
        #     [[a, b], [[[c, d], some_position]]],
        #     [[m], []]]
        #   ],
        # where _a_, _b_ - atoms that belongs to one face of crystal on which can be
        # applied one multistep operation when each neighbour atoms checing; each
        # neighbour atoms compares with _c_ and _d_; _m_ is additional checking atom.
        # TODO: must be private
        def algorithm_graph
          #
          # для кажого атома:
          # группируем отношения по фейсу и диру
          # одинаковые ненаправленные связи - отбрасываем
          #
          # для каждой группы:
          # проверяем по кристаллу максимальное количество отношений такого рода, и
          #   если количество соответствует - удаляем обратные связи, заодно удаляя
          #   из ключей хеша и атомы, если у них более не остаётся отношений
          # если меньше - проверяем тип связанного атома, и если он соответствует
          #   текущему атому - удаляем обратную связь (симметричный димер), заодно
          #   удаляя из ключей хеша и сам атом, если у него более не остаётся отношений
          # если больше - кидаем эксепшн
          #
          # между всеми атомами, что участвовали в отчистке, удаляем позишины, и
          # также, если у атома в таком случае не остаётся отношений, - удаляем его
          # из эссенции

          result = cut_graph
          clear_reverse = -> reverse_atom, from_atom do
            result = clear_reverse_from(result, reverse_atom, from_atom)
          end

          # in accordance with the order
          sequence.short.each do |atom|
            next unless result[atom]

            limits = atom.relations_limits
            groups = result[atom].group_by { |_, r| r.params }
            groups.each do |rel_params, group|
              if limits[rel_params] < unificate(group).size
                raise 'Atom has too more relations'
              end
            end

            clear_reverse_relations = proc { |a, _| clear_reverse[a, atom] }

            amorph_rels = groups.delete(Concepts::Bond::AMORPH_PROPS)
            if amorph_rels
              amorph_rels.each(&clear_reverse_relations)
              crystal_rels = result[atom].select { |_, r| r.belongs_to_crystal? }
              result[atom] = crystal_rels + unificate(amorph_rels)
            end

            next unless atom.lattice

            groups.each do |rel_params, group|
              if limits[rel_params] == group.size
                group.each(&clear_reverse_relations)
              else
                first_prop = Organizers::AtomProperties.new(spec, atom)
                group.each do |a, _|
                  second_prop = Organizers::AtomProperties.new(spec, a)
                  clear_reverse[a, atom] if first_prop == second_prop
                end
              end
            end
          end

          result
        end

        # Gets the atoms of cut links graph which are grouped by available neighbours
        # which are available through flatten relations that belongs to some crystal
        # face
        #
        # @return [Array] the array of arrays where each group contain similar related
        #   atoms
        # TODO: must be private
        def grouped_anchors
          groups = cut_links.keys.group_by do |atom|
            Set.new(flatten_neighbours_for(atom) + [atom])
          end
          groups.values
        end

        # Gets anchors by which will be first check of find algorithm
        # @return [Array] the major anchors of current specie
        # TODO: must be private
        def central_anchors
          scas =
            if spec.complex? && (mua = most_used_anchor)
              [mua]
            else
              tras = together_related_anchors
              tras.empty? ? root_related_anchors : tras
            end

          if scas.empty? || lists_are_identical?(scas, major_anchors, &:==)
            [major_anchors]
          else
            scas.map { |a| [a] }
          end
        end

      private

        attr_reader :spec, :sequence

        # Unificate list of relations by checking that each relation is unique or not
        # @param [rels]
        def unificate(rels)
          twins = spec.rest ? rels.map { |a, _| spec.rest.all_twins(a) }.uniq : []
          twins.flatten.size < rels.size ? rels.uniq : rels
        end

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

        # Gets relation from cut links graph between passed atoms
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   first atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   second atom
        # @return [Concepts::Bond] the found relation
        def cut_relation_between(first, second)
          cut_links[first].select { |a, _| a == second }.first.last
        end

        # Gets all relations which take a place between passed sets of atoms
        # @param [Array] atoms the set of atoms from which relations will be observed
        # @param [Array] neighbours to which relations will be found
        # @return [Array] the array of relations between each pair of atoms from passed
        #   sets, which have size same as atoms and neighbours arrays
        def relations_between(atoms, neighbours)
          atoms.zip(neighbours).map { |a, b| cut_relation_between(a, b) }
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
        def flatten_relations_only_in?(group, atom)
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
          grouped_anchors.each_with_object([[], []]) do |group, acc|
            acc.first << group if group.any? do |atom|
              has_flatten_relation?(atom) && !flatten_relations_only_in?(group, atom)
            end

            acc.last << group if group.any? do |atom|
              dept_only_from_group = flatten_relations_only_in?(group, atom)
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
        # @yield [Array, Array] iterates each case after getting relations for each
        #   atom from group; the first argument of block procedure is array of atoms,
        #   which was combined when method do, but every time it array contain just one
        #   item which is iterating atom; the second argument of block procedure is
        #   content for iterating atom relatoins array
        def combine_similar_relations(group, &block)
          group.each do |atom|
            key = [atom]
            rels = cut_links[atom]

            if rels.empty?
              block[key, nil]
            else
              groupable_rels = flatten_relations_only_in?(group, atom) ?
                rels : non_flatten_relations_of(atom)

              similar_rels_groups = groupable_rels.group_by do |a, r|
                [Organizers::AtomProperties.new(spec, a), r.params]
              end

              similar_rels_groups.values.each do |similar_rels|
                block[key, similar_rels.transpose]
              end
            end
          end
        end

        # Clears reverse relations from links hash between reverse_atom and from_atom.
        # If revese_atom has no relations after clearing then reverse_atom removes too.
        #
        # @param [Hash] links which will be cleared
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   reverse_atom the atom whose relations will be erased
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   from_atom the atom to which relations will be erased
        # @return [Hash] the links without correspond relations and reverse_atom if it
        #   necessary
        def clear_reverse_from(links, reverse_atom, from_atom)
          reject_proc = proc { |a, _| a == from_atom }
          clear_links(links, reject_proc) { |a| a == reverse_atom }
        end

        # Clears relations from links hash where each purging relatoins list selected
        # by condition lambda and purification doing by reject_proc
        #
        # @param [Hash] links which will be cleared
        # @param [Proc] reject_proc the function of two arguments which doing for
        #   reject excess relations
        # @yield [Atom] by it condition checks that erasing should to be
        # @return [Hash] the links without erased relations
        def clear_links(links, reject_proc, &condition_proc)
          links.each_with_object({}) do |(atom, rels), result|
            if condition_proc[atom]
              new_rels = rels.reject(&reject_proc)
              result[atom] = new_rels unless new_rels.empty?
            else
              result[atom] = rels
            end
          end
        end

        # Finds parent specie and correspond twin atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #parents_with_twins_for same argument
        # @return [Array] the array where first item is parent specie and second item
        #   is twin atom of passed atom
        def parent_with_twin_for(atom)
          parents_with_twins_for(atom).first
        end

        # Finds parent specie
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #parents_with_twins_for same argument
        # @return [Specie] the specie which uses twin of passed atom
        def parent_for(atom)
          pwt = parent_with_twin_for(atom)
          pwt && pwt.first
        end

        # Counts relations of atom which selecting by block
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which relations will be counted
        # @yield [Concepts::Bond | Concepts::TerminationSpec] iterates inspectable
        #   relations if given
        # @return [Integer] the number of selected relations
        def count_relations(atom, &block)
          rels = spec.relations_of(a)
          rels = rels.select(&block) if block_given?
          rels.size
        end

        # Counts twins of atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which twins will be counted
        # @return [Integer] the number of twins
        def count_twins(atom)
          spec.rest ? spec.rest.twins_num(atom) : 0
        end

        # Compares two atoms by method name and order it descending
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   a is first atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   b is second atom
        # @param [Symbol] method_name by which atoms will be compared
        # @param [Symbol] detect_method if passed ten will passed as block in
        #   comparation method
        # @yield calling when atoms is same by used method
        # @return [Integer] the order of atoms
        def order(a, b, method_name, detect_method = nil, &block)
          if detect_method
            ca = send(method_name, a, &detect_method)
            cb = send(method_name, b, &detect_method)
          else
            ca = send(method_name, a)
            cb = send(method_name, b)
          end

          if ca == cb
            block.call
          else
            ca <=> cb
          end
        end

        # Gives the largest atom that has the most number of links in a complex specie,
        # and hence it is closer to specie center
        #
        # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   the largest atom of specie
        def big_anchor
          sequence.major_atoms.max do |a, b|
            pa = Organizers::AtomProperties.new(spec, a)
            pb = Organizers::AtomProperties.new(spec, b)
            if pa == pb
              0
            elsif !pa.include?(pb) && !pb.include?(pa)
              order(a, b, :count_twins) do
                order(a, b, :count_relations, :relations?) do
                  order(a, b, :count_relations, :bond?) do
                    order(a, b, :count_relations) { 0 }
                  end
                end
              end
            elsif pa.include?(pb)
              1
            else # pb.include?(pa)
              -1
            end
          end
        end

        # Selects most used anchor which have the bigger number of twins
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   the most used anchor of specie or nil
        def most_used_anchor
          ctn_mas = sequence.major_atoms.map { |a| [a, count_twins(a)] }
          max_twins_num = ctn_mas.reduce(0) { |acc, (_, ctn)| ctn > acc ? ctn : acc }
          all_max = ctn_mas.select { |_, ctn| ctn == max_twins_num }.map(&:first)
          all_max.size == 1 ? all_max.first : nil
        end

        # Filters major anchors from atom sequence
        # @return [Array] the realy major anchors of current specie
        def major_anchors
          if spec.source?
            [sequence.major_atoms.first]
          elsif spec.complex?
            [big_anchor]
          else
            sequence.major_atoms
          end
        end

        # Gets anchors which have relations
        # @return [Array] the array of atoms with relations in pure essence
        def bonded_anchors
          @essence.reject { |_, links| links.empty? }.map(&:first)
        end

        # Selects atoms from pure essence which have mutual relations
        # @return [Array] the array of together related atoms
        def together_related_anchors
          bonded_anchors.select do |atom|
            @essence[atom].any? do |a, _|
              pels = @essence[a]
              pels && pels.any? { |q, _| q == atom }
            end
          end
        end

        # Selects those atoms with links that are not related any other atoms are
        # @return [Array] the array of root related atoms
        def root_related_anchors
          bonded_anchors.reject do |atom|
            comp_proc = proc { |a, _| a == atom }
            @essence.reject(&comp_proc).any? { |_, links| links.any?(&comp_proc) }
          end
        end
      end

    end
  end
end
