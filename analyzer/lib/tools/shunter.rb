module VersatileDiamond
  module Tools

    # Organizes the relationship between the concepts
    class Shunter

      REACTION_KEYS =
        [:ubiquitous_reaction, :reaction, :lateral_reaction].freeze

      # Exception for case when some reactions overlap
      class ReactionDuplicate < Errors::Base
        attr_reader :first, :second
        # @param [String] first the name of first reaction
        # @param [String] second the name of second reaction
        def initialize(first, second); @first, @second = first, second end
      end

      class << self
        # Organize dependecies between concepts stored in Chest
        # @raise [ReactionDuplicate] if was defined some duplicate of reaction
        def organize_dependecies!
          # order of organization is important!
          purge_null_rate_reactions!
          organize_specific_spec_dependencies!

          # before need to update specs by organize their dependecies!
          check_reactions_for_duplicates
          organize_reactions_dependencies!

          organize_specs_dependencies!
          purge_unused_specs!
        end

      private

        # Reorganize dependencies between base specs
        def organize_specs_dependencies!
          specs = Chest.all(:surface_spec)
          # sorts ascending size
          specs.sort! do |a, b|
            if a.size == b.size
              b.external_bonds <=> a.external_bonds
            else
              a.size <=> b.size
            end
          end
          specs.each_with_object([]) do |spec, possible_parents|
            spec.organize_dependencies!(possible_parents)
            possible_parents.unshift(spec)
          end
        end

        # Organize dependencies between specific species
        def organize_specific_spec_dependencies!
          collect_specific_specs!
          purge_unused_extended_specs!
          purge_unspecified_specs!

          specific_specs = Chest.all(:specific_spec)
          specific_specs.each_with_object({}) do |ss, specs|
            base_spec = ss.spec
            specs[base_spec] ||= specific_specs.select do |s|
              s.spec == base_spec
            end
            ss.organize_dependencies!(specs[base_spec])
          end
        end

        # Checks stored reactions for duplication with each other
        # @raise [ReactionDuplicate] if duplicate is found
        def check_reactions_for_duplicates
          REACTION_KEYS.each do |key|
            reactions = Chest.all(key).dup
            until reactions.empty?
              reaction = reactions.pop
              same = reactions.find { |r| r != reaction && reaction.same?(r) }
              raise ReactionDuplicate.new(reaction.name, same.name) if same
            end
          end
        end

        # Organize dependencies between all stored reactions
        def organize_reactions_dependencies!
          not_ubiquitous_reactions = typical_reactions + lateral_reactions

          # order of dependencies organization is important!
          Chest.all(:ubiquitous_reaction).each do |reaction|
            reaction.organize_dependencies!(not_ubiquitous_reactions)
          end
          lateral_reactions.each do |reaction|
            reaction.organize_dependencies!(lateral_reactions)
          end
          typical_reactions.each do |reaction|
            reaction.organize_dependencies!(lateral_reactions)
          end
        end

        # Removes all unused base specs from Chest
        def purge_unused_specs!
          purge_excess_extrime_specs!

          specs = Chest.all(:gas_spec, :surface_spec)
          specific_specs = Chest.all(:specific_spec)

          specs.each do |spec|
            has_parent = specs.any? { |s| s.parent == spec }
            has_children = has_parent || specific_specs.any? do |specific_spec|
              specific_spec.spec == spec
            end

            Chest.purge!(spec) unless has_children
          end
        end

        # Purges all extrime base spec if some have just one child and it
        # child is unspecified specific spec
        def purge_excess_extrime_specs!
          unspecified_specs = Chest.all(:specific_spec).select do |spec|
            !spec.specific? && !spec.parent
          end

          unspecified_specs.each do |specific_spec|
            base_spec = specific_spec.spec
            next unless base_spec.childs.size == 1 && base_spec.theres.empty?

            base_parent = base_spec.parent
            next unless base_parent

            specific_spec.update_base_spec(base_parent)
            base_parent.remove_child(base_spec)
            base_parent.store_child(specific_spec)

            Chest.purge!(base_spec)
          end
        end

      end
    end

  end
end
