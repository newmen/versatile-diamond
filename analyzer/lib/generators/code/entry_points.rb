module VersatileDiamond
  module Generators
    module Code

      # Provides logic for selecting entry points of find specie algorithm
      class EntryPoints
        include Modules::OrderProvider
        include AtomPropertiesUser
        include TwinsHelper
        extend Forwardable

        # Initializes entry points detector by specie
        # @param [Specie] specie for which find algorithm will builded
        def initialize(specie)
          @specie = specie
          @_list = nil
        end

        # Gets entry points of find algorithm
        # @return [Array] the ordered entry points, each point as array of specie atoms
        def list
          @_list ||=
            if spec.source?
              [atom_point(sequence.major_atoms.first)]
            elsif spec.complex?
              uniq_cas = most_different_connection_atoms
              if uniq_cas # is edge connected graph?
                uniq_cas.map(&method(:atom_point))
              else
                [atom_point(most_used_anchor || big_anchor)]
              end
            else # there is just one parent specie
              [parent_specie_points]
            end
        end

      private

        def_delegators :@specie, :spec, :sequence

        # Collects atoms which are have relation between each collected pair of atoms
        # @return [Array] the array of pairs of connected atoms which are belongs to
        #   different parent species
        def connection_atoms
          inspected_anchors = spec.anchors.to_set
          spec.clean_links.each_with_object([]) do |(v, rels), result|
            next unless inspected_anchors.include?(v)

            rels.each do |w, _|
              next unless inspected_anchors.include?(w)

              pair = [v, w]
              next if result.include?(pair) || result.include?([w, v])

              pwts = find_and_sort_parents(*pair)
              next unless pwts

              vpwts, wpwts = pwts
              vps, vts = vpwts.transpose
              wps, wts = wpwts.transpose

              common_parents = vps & wps
              result << pair if (!common_parents.empty? && !(vts & wts).empty?) ||
                (common_parents.empty? && !vertex_connected?(vps, wps))
            end
          end
        end

        # Finds and sorts parents for each of passed atoms. Order of passed atoms does
        # not matter.
        #
        # @param [Array] pair atoms for which parent species will be found
        # @return [Array] the two elements array of sorted parents with twins or nil
        #   if parent specie for some atom was not found
        def find_and_sort_parents(*pair)
          sorted_parents = spec.parents.sort
          parents_with_twins_for_both = pair.map(&method(:parents_with_twins_for))
          real_pwts = parents_with_twins_for_both.reject(&:empty?)
          return nil unless real_pwts.size == 2

          real_pwts.sort_by do |pwts|
            pwts.map { |p, _| sorted_parents.index(p) }.min
          end
        end

        # Checks that some of passed parents have common atom
        # @param [Array] firsts parents list for check
        # @param [Array] seconds parents list for check
        # @return [Boolean] are have common atom or not
        def vertex_connected?(firsts, seconds)
          spec.anchors.any? do |atom|
            prs = parents_for(atom)
            prs.size > 1 && !(prs & firsts).empty? && !(prs & seconds).empty?
          end
        end

        # Rejects connection atoms if them are identical
        # @return [Array] the array of pairs of different connected atoms which are
        #   belongs to different parent species
        def most_different_connection_atoms
          diff_pairs = connection_atoms.reject do |a, b|
            pa, pb = aps_from(a, b)
            pa == pb
          end

          sorted_pairs = diff_pairs.sort_by do |pair|
            -pair.map { |a| spec.relations_of(a).size }.max
          end

          sorted_pairs.first
        end

        # Collects parent species in which using the passed atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #parents_with_twins_for same argument
        # @return [Array] the array of parent species which using passed atom
        def parents_for(atom)
          parents_with_twins_for(atom).map(&:first)
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

        # Gives the largest atom that has the most number of links in a complex specie,
        # and hence it is closer to specie center
        #
        # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   the largest atom of specie
        def big_anchor
          sequence.major_atoms.max do |a, b|
            pa, pb = aps_from(a, b)
            if pa == pb
              0
            elsif !pa.include?(pb) && !pb.include?(pa)
              order(a, b, :count_twins) do
                order(a, b, :count_relations, :relations?) do
                  order(a, b, :count_relations, :bond?) do
                    order(a, b, :count_relations)
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
        # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   the most used anchor of specie or nil
        def most_used_anchor
          ctn_mas = sequence.major_atoms.map { |a| [a, count_twins(a)] }
          max_twins_num = ctn_mas.reduce(0) { |acc, (_, ctn)| ctn > acc ? ctn : acc }
          all_max = ctn_mas.select { |_, ctn| ctn == max_twins_num }.map(&:first)
          all_max.size == 1 ? all_max.first : nil
        end

        # Wraps atom for using it as entry point
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be wrapped
        # @return [Array] the wrapped atom
        def atom_point(atom)
          [atom]
        end

        # Gets wrapped sequence of parent specie atoms which will be used as entry
        # point
        #
        # @return [Array] the atoms which could be gotten from single parent specie
        def parent_specie_points
          spec.anchors.reject { |a| parents_for(a).empty? }
        end
      end

    end
  end
end
