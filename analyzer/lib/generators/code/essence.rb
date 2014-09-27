module VersatileDiamond
  module Generators
    module Code

      # Contain logic for clean dependent specie and get essence of specie graph
      class Essence
        include Modules::ListsComparer

        # Initizalize cleaner by specie class code generator
        # @param [Specie] specie from which pure essence will be gotten
        def initialize(specie)
          @spec = specie.spec
          @sequence = specie.sequence
          @essence = clean_graph
        end

        # Checks that finding specie is source specie
        # @return [Boolean] is source specie or not
        def source?
          spec.parents.size == 0
        end

        # Checks that finding specie have more than one parent
        # @return [Boolean] have many parents or not
        def complex?
          spec.parents.size > 1
        end

        # Gets a links of current specie without links of parent species
        # @return [Hash] the link between atoms without links of parent species
        # TODO: must be private
        def cut_graph
          rest = spec.rest
          return spec.spec.links unless rest

          atoms = rest.links.keys
          clear_links = rest.links.map do |atom, rels|
            [atom, rels.select { |a, _| atom != a && atoms.include?(a) }]
          end

          twins = atoms.map { |atom| rest.all_twins(atom).dup }
          twins = Hash[atoms.zip(twins)]

          result = spec.parents.reduce(clear_links) do |acc, parent|
            acc.map do |atom, rels|
              parent_links = parent.links
              parent_atoms = twins[atom]
              clear_rels = rels.reject do |a, r|
                pas = twins[a]
                !pas.empty? && parent_atoms.any? do |p|
                  ppls = parent_links[p]
                  ppls && ppls.any? { |q, y| r == y && pas.include?(q) }
                end
              end

              [atom, clear_rels]
            end
          end

          Hash[result]
        end

        # Gets an essence of wrapped dependent spec but without reverse relations if
        # related atoms is similar. The nearer to top of achchors sequence, have more
        # relations in essence.
        #
        # @param [Specie] specie for which pure essence will be gotten
        # @return [Hash] the links hash without reverse relations
        # TODO: must be private
        def clean_graph
          # для кажого атома:
          # группируем отношения по фейсу и диру
          # одинаковые ненаправленные связи - отбрасываем
          #
          # для каждой группы:
          # проверяем по кристаллу максимальное количество отношений такого рода, и
          #   если количество соответствует - удаляем обратные связи, заодно удаляя
          #   из хеша и атомы, если у них более не остаётся отношений
          # если меньше - проверяем тип связанного атома, и если он соответствует
          #   текущему атому - удаляем обратную связь, заодно удаляя из хеша и сам
          #   атом, если у него более не остаётся отношений
          # если больше - кидаем эксепшн
          #
          # между всеми атомами, что участвовали в отчистке, удаляем позишины, и
          # также, если у атома в таком случае не остаётся отношений, - удаляем его
          # из эссенции

          result = cut_graph
          clearing_atoms = Set.new
          clear_reverse = -> reverse_atom, from_atom do
            clearing_atoms << from_atom << reverse_atom
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

          clear_excess_positions(result, clearing_atoms)
        end

        # Gets anchors by which will be first check of find algorithm
        # @return [Array] the major anchors of current specie
        # TODO: must be private
        def central_anchors
          scas =
            if complex? && (mua = most_used_anchor)
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

        # Clears position relations which are between atom from clearing_atoms
        # @param [Hash] links which will be cleared
        # @param [Set] clearing_atoms the atoms between which positions will be erased
        # @return [Hash] the links without erased positions
        def clear_excess_positions(links, clearing_atoms)
          # there is could be only realy bonds and positions
          reject_proc = proc do |a, r|
            spec.relations_of(a).select(&:bond?).all?(&:belongs_to_crystal?) &&
              !r.bond? && clearing_atoms.include?(a)
          end
          clear_links(links, reject_proc) { |a| clearing_atoms.include?(a) }
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
          spec.rest.all_twins(atom).size
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
          if source?
            [sequence.major_atoms.first]
          elsif complex?
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
