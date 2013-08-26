module VersatileDiamond
  module Tools

    # Organizes the relationship between the concepts
    class Shunter

      REACTION_KEYS =
        [:ubiquitous_reaction, :reaction, :lateral_reaction].freeze

      # Exception for case when some reactions overlap
      class ReactionDuplicate < Exception
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

        # Removes all reactions with full rate equal 0 from Chest
        def purge_null_rate_reactions!
          each_reaction do |reaction|
            Chest.purge!(reaction) if reaction.full_rate == 0
          end
        end

        # Organize dependencies between specific species
        def organize_specific_spec_dependencies!
          collect_specific_specs!
          specific_specs = Chest.all(:specific_spec)
          specific_specs.each_with_object({}) do |ss, specs|
            base_spec = ss.spec
            specs[base_spec] ||= specific_specs.select do |s|
              s.spec == base_spec
            end
            ss.organize_dependencies!(specs[base_spec])
          end
        end

        # Collects specific species from all reactions and store them to
        # internal sac variable. Each spec must be already looked around!
        # At collecting time swaps reaction source spec with another same spec
        # (with same name) if it another spec already collected.
        def collect_specific_specs!
          specs = each_reaction.with_object({}) do |reaction, hash|
            reaction.each_source do |specific_spec|
              full_name = specific_spec.full_name
              if hash[full_name]
                reaction.swap_source(specific_spec, hash[full_name])
              else
                hash[full_name] = specific_spec
              end
            end
          end

          specs.values.each do |specific_spec|
            Chest.store(specific_spec, method: :full_name)
          end
        end

        # Checks stored reactions for duplication with each other
        # @raise [ReactionDuplicate] if duplicate is found
        def check_reactions_for_duplicates
          checker = -> reactions do
            reactions = reactions.dup
            until reactions.empty?
              reaction = reactions.pop
              same = reactions.find { |r| r != reaction && reaction.same?(r) }
              raise ReactionDuplicate.new(reaction.name, same.name) if same
            end
          end

          REACTION_KEYS.each { |key| checker[Chest.all(key)] }
        end

        # Organize dependencies between all stored reactions
        def organize_reactions_dependencies!
          typical_reactions = Chest.all(:reaction)
          lateral_reactions = Chest.all(:lateral_reaction)
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
          specs = Chest.all(:gas_spec, :surface_spec)
          specific_specs = Chest.all(:specific_spec)
          lateral_reactions = Chest.all(:lateral_reaction)

          specs.each do |spec|
            has_parent = specs.any? { |s| s.parent == spec }
            has_children = has_parent || specific_specs.any? do |specific_spec|
              specific_spec.spec == spec
            end
            has_depend = has_children || lateral_reactions.any? do |reaction|
              reaction.theres.any? { |there| there.specs.include?(spec) }
            end

            Chest.purge!(spec) unless has_depend
          end
        end

        # Iterates all reactions
        # @yield [Concepts::UbiquitoursReaction] do for each reaction
        # @return [Enumerator] if block is not given
        def each_reaction(&block)
          reactions = Chest.all(*REACTION_KEYS)
          block_given? ? reactions.each(&block) : reactions.each
        end
      end
    end

  end
end
