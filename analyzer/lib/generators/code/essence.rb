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

          @_cut_links = nil
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

        # Gets the hash with main links between major anchors
        # @return [Hash] the links between self anchor atoms and another possible major
        #   atoms of parent species
        def anchors_links
          spec.clean_links.each_with_object({}) do |(atom, rels), acc|
            acc[atom] = select_rels(atom, rels).uniq if anchor?(atom)
          end
        end

        # Checks that passed atom is anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be checked
        # @return [Boolean] is anchor or not
        def anchor?(atom)
          spec.anchors.include?(atom)
        end

        # Selects relations from passed set
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which relations will be filtered
        # @param [Hash] rels are relations of passed atom in current specie
        # @return [Hash] the relations between major atoms which are have some
        #   different properties
        def select_rels(atom, rels)
          rels.select do |a, r|
            a != atom && anchor?(a) &&
              (diff_parents?(atom, a) || required_relation?(atom, a, r))
          end
        end

        # Checks that passed atoms are anchors of not same parent specie
        # @param [Array] atoms which will be checked
        # @return [Boolean] are passed atoms used in several different parent species
        #   or not
        def diff_parents?(*atoms)
          all_parents = parents_from(atoms)
          anchored_parents = parents_from(atoms, anchored: true)
          any_anchored_empty = anchored_parents.any?(&:empty?)

          # all parent species are different
          (!any_anchored_empty && anchored_parents.reduce(:&).empty?) ||
            # any anchor is presented just in current specie
            (any_anchored_empty && all_parents.any?(&:empty?)) ||
            # atoms are not anchors in parent species but species are different
            (anchored_parents.all?(&:empty?) && all_parents.reduce(:&).empty?)
        end

        # Checks that relation between passed atoms is not excess position
        # @param [Array] atoms between which the relation will be checked
        # @param [Concepts::Bond] rel which will be checked
        # @return [Boolean] is required not bond relation or not
        def required_relation?(*atoms, rel)
          rel.relation? &&
            (!rel.bond? || parents_from(atoms).reduce(:&).empty?) &&
            atoms.permutation.all? do |a1, a2|
              spec.residual_links[a1].include?([a2, rel])
            end
        end

        # Gets list of parent species for each of passed atoms where it used
        # @param [Array] atoms for which the parent species will be collected
        # @return [Array] the lists of parent species
        def parents_from(atoms, anchored: false)
          atoms.map { |atom| spec.parents_of(atom, anchored: anchored) }
        end
      end

    end
  end
end
