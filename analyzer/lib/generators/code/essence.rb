module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contain logic for clean dependent specie and get essence of specie graph
      class Essence
        # Initizalize cleaner by specie
        # @param [Organizers::DependentWrappedSpec] spec from which the pure essence
        #   will be gotten
        def initialize(spec)
          @spec = spec

          @_cut_links, @_main_links = nil
        end

        # Gets a links of current specie without not majored links of parent species
        # @return [Hash] the major links between anchor atoms
        def cut_links
          @_cut_links ||=
            if spec.source?
              Hash[spec.clean_links.map { |a, rels| [a, rels.uniq] }]
            else
              Hash[anchors_links]
            end
        end

      private

        attr_reader :spec

        # Checks that at least one anchor of each parent specie was resolved
        # completely at stage of specie residual calculation
        #
        # @return [Boolean] are all parent species have at least one anchor in
        #   collected main links or not
        def all_main_anchors?
          main_links.keys.all? { |a| spec.main_anchors.include?(a) }
        end

        # Gets the hash with links between all significant atoms
        # @return [Hash] the links between self and parents anchor atoms
        def anchors_links
          all_main_anchors? ? main_links : extended_links
        end

        # Gets the hash with main links between major anchors
        # @return [Hash] the links between self anchor atoms and another possible major
        #   atoms of parent species
        def main_links
          @_main_links ||=
            spec.clean_links.each_with_object({}) do |(atom, rels), acc|
              if anchor?(atom)
                acc[atom] = select_rels(atom, rels, &method(:diff_parents?)).uniq
              end
            end
        end

        # Extends default main links by relations between empty related anchors which
        # corresponds to different parent anchors
        #
        # @return [Hash] the links between all significant anchors of both generations
        def extended_links
          spec.clean_links.each_with_object(main_links.dup) do |(atom, rels), acc|
            if empty_related_anchor?(atom)
              major_rels = select_rels(atom, rels, &method(:missed_rel?))
              acc[atom] = major_rels.uniq unless major_rels.empty?
            end
          end
        end

        # Checks that passed atom already presents in main links and it relations are
        # empty
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is passed atom a unique anchor with empty relations or not
        def empty_related_anchor?(atom)
          main_links[atom] && main_links[atom].empty?
        end

        # Checks that passed atom is own anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is own anchor or not
        def anchor?(atom)
          spec.anchors.include?(atom)
        end

        # Selects relations from passed set
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which relations will be filtered
        # @param [Hash] rels are relations of passed atom in current specie
        # @yield [Atom, Atom] checks difference between related atoms
        # @return [Hash] the relations between major atoms which are have some
        #   different properties
        def select_rels(atom, rels, &block)
          rels.select { |a, _| a != atom && anchor?(a) && block[atom, a] }
        end

        # Checks that relation between passed atoms is missed
        # @param [Array] atoms the relation between which will be checked
        # @return [Boolean] is missed relation between atoms or not
        def missed_rel?(*atoms)
          !anchors_of_one_parent?(*atoms)
        end

        # Checks that passed atoms are used in several different parent species
        # @param [Array] atoms which will be checked
        # @return [Boolean] are passed atoms used in several different parent species
        #   or not
        def diff_parents?(*atoms)
          parents_from(atoms).reduce(:&).empty?
        end

        # Checks that passed atoms are anchors of to same parent specie
        # @return [Array] atoms wich will be checked
        # @return [Boolean] are passed atoms used in same parent specie or not
        def anchors_of_one_parent?(*atoms)
          !parents_from(atoms, anchored: true).reduce(:&).empty?
        end

        # Gets list of parent species where it used for each of passed atoms
        # @param [Array] atoms for which the parent species will be collected
        # @option [Boolean] :anchored the flag which says that each twin atom in
        #   correspond parent specie should be an anchor
        # @return [Array] the lists of parent species where parent species of one list
        #   are used the same atom
        def parents_from(atoms, anchored: false)
          atoms.map { |atom| spec.parents_of(atom, anchored: anchored) }
        end
      end

    end
  end
end
