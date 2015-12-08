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

          @_cut_links, @_own_links = nil
          @_sliced_parents_anchors, @_anchors_mirror, @_parents_anchors = nil
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
        # @return [Boolean] are all parent species have at least one anchor in
        #   collected unique links or not
        def all_parents_anchors_added?
          added_anchors = uniq_links.keys
          sliced_parents_anchors.all? { |atoms| !(added_anchors & atoms).empty? }
        end

        # Gets the hash with links between all significant atoms
        # @return [Hash] the links between self and parents anchor atoms
        def anchors_links
          all_parents_anchors_added? ? uniq_links : major_links
        end

        # Gets the hash with unique links between major anchors
        # @return [Hash] the links between self anchor atoms and another possible major
        #   atoms of parent species
        def uniq_links
          @_own_links ||=
            spec.clean_links.each_with_object({}) do |(atom, rels), acc|
              if major_anchor?(atom)
                major_rels = select_major_rels(atom, rels, &method(:not_same_parents?))
                acc[atom] = major_rels.uniq if own_anchor?(atom) || !major_rels.empty?
              end
            end
        end

        # Extends default unique links for the atoms which are anchors of parent specs
        # @return [Hash] the links between all significant anchors of both generations
        def major_links
          spec.clean_links.each_with_object(uniq_links.dup) do |(atom, rels), acc|
            if parent_anchor?(atom) || empty_uniq_anchor?(atom)
              major_rels = select_major_rels(atom, rels, &method(:major_rel?))
              acc[atom] = major_rels.uniq unless major_rels.empty?
            end
          end
        end

        # Checks that passed atom already presents in unique links and it relations are
        # empty
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is passed atom a unique anchor with empty relations or not
        def empty_uniq_anchor?(atom)
          uniq_links[atom] && uniq_links[atom].empty?
        end

        # Selects major relations from passed set
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which relations will be filtered
        # @param [Hash] rels are relations of passed atom in current specie
        # @yield [Atom, Atom] checks difference between related atoms
        # @return [Hash] the relations between major atoms which are have some
        #   different properties
        def select_major_rels(atom, rels, &block)
          rels.select { |a, _| a != atom && major_anchor?(a) && block[atom, a] }
        end

        # Makes the mirror of twin parent atoms to own atoms
        # @return [Hash] the mapping of all twin atoms to correponding own atoms
        def anchors_mirror
          return @_anchors_mirror if @_anchors_mirror

          atoms = spec.links.keys
          twins = atoms.map(&spec.public_method(:twins_of))

          pairs = twins.zip(atoms).flat_map { |tws, a| tws.zip([a] * tws.size) }
          @_anchors_mirror = Hash[pairs]
        end

        # Provides the set of parent specie anchors spliced by specie where each atom
        # was
        #
        # @return [Array] the list of slices of parent species anchors
        def sliced_parents_anchors
          @_sliced_parents_anchors ||=
            spec.parents.reject(&:source?).map(&:anchors).map do |atoms|
              atoms.map { |a| anchors_mirror[a] }
            end
        end

        # Collects the atoms which are anchors in the parent species (if the parent is
        # not source specie)
        #
        # @return [Set] the set of own atoms which corresponds to anchor atoms of
        #   parent species
        def parents_anchors
          @_parents_anchors ||= sliced_parents_anchors.flatten.compact.to_set
        end

        # Checks that passed atom correspond to parent anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is correspond to parent anchor or not
        def parent_anchor?(atom)
          parents_anchors.include?(atom)
        end

        # Checks that passed atom is own anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is own anchor or not
        def own_anchor?(atom)
          spec.anchors.include?(atom)
        end

        # Checks that passed atom correspond to parent anchor or is own anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is correspond to parent anchor or own anchor or not
        def major_anchor?(atom)
          own_anchor?(atom) || parent_anchor?(atom)
        end

        # Checks that relation between passed atoms is major
        # @param [Array] atoms the relation between which will be checked
        # @return [Boolean] is major relation between atoms or not
        def major_rel?(*atoms)
          !resolved?(*atoms) && with_diff_parents?(*atoms)
        end

        # Checks that all passed atoms already uses as keys in unique links result
        # @param [Array] atoms which will be checked
        # @return [Boolean] are all atoms resolved or not
        def resolved?(*atoms)
          atoms.all? { |a| uniq_links[a] }
        end

        # Checks that passed atoms are used in several different parent species
        # @param [Array] atoms which will be checked
        # @return [Boolean] are passed atoms used in several different parent species
        #   or not
        def with_diff_parents?(*atoms)
          parents = parents_from(atoms)
          parents.any?(&:empty?) || !parents.reduce(:+).all_equal?
        end

        # Checks that passed atoms are not belongs to same parent specie
        # @return [Array] atoms wich will be checked
        # @return [Boolean] are passed atoms used in same parent specie or not
        def not_same_parents?(*atoms)
          parents_from(atoms).reduce(:&).empty?
        end

        # Gets list of parent species where it used for each of passed atoms
        # @param [Array] atoms for which the parent species will be collected
        # @return [Array] the lists of parent species where parent species of one list
        #   are used the same atom
        def parents_from(atoms)
          atoms.map(&spec.public_method(:parents_of))
        end
      end

    end
  end
end
