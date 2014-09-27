module VersatileDiamond
  module Generators
    module Code

      # Contain logic for clean dependent specie and get essence of specie graph
      class Essence

        # Initizalize cleaner by specie class code generator
        # @param [Specie] specie from which pure essence will be gotten
        def initialize(specie)
          @spec = specie.spec
          @sequence = specie.sequence
        end

        # Gets a links of current specie without links of parent species
        # @return [Hash] the links between atoms without links of parent species
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
        # @param [Concepts::Atom] reverse_atom the atom whose relations will be erased
        # @param [Concepts::Atom] from_atom the atom to which relations will be erased
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
      end

    end
  end
end
