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

        # Removes all reactions with full rate equal 0 from Chest
        def purge_null_rate_reactions!
          each_reaction do |reaction|
            Chest.purge!(reaction) if reaction.full_rate == 0
          end
        end

        # Organize dependencies between specific species
        def organize_specific_spec_dependencies!
          collect_specific_specs!
          purge_unused_extended_specs!

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
        # internal chest variable. Each spec must be already looked around!
        # At collecting time swaps reaction source spec with another same spec
        # (with same name) if it another spec already collected.
        # Each specific spec stores reaction or theres from which it dependent.
        def collect_specific_specs!
          cache = {}
          store_lambda = -> concept do
            -> specific_spec do
              full_name = specific_spec.full_name
              if cache[full_name]
                concept.swap_source(specific_spec, cache[full_name])
              else
                cache[full_name] = specific_spec
              end

              store_concept_to(concept, cache[full_name])
            end
          end

          each_reaction do |reaction|
            reaction.each_source(&store_lambda[reaction])
          end

          lateral_reactions.each do |reaction|
            reaction.theres.each do |there|
              there.env_specs.each(&store_lambda[there])
            end
          end

          cache.values.each do |specific_spec|
            Chest.store(specific_spec, method: :full_name)
          end
        end

        # Purges extended spec if atoms of each one can be used as same in
        # reduced spec
        def purge_unused_extended_specs!
          extended_specs = Chest.all(:specific_spec).select do |spec|
            spec.reduced && spec.could_be_reduced?
          end

          extended_specs.each do |ext_spec|
            check_that_can = -> concept do
              used_keynames = concept.used_keynames_of(ext_spec)
              Concepts::Spec.good_for_reduce?(used_keynames)
            end

            next unless ext_spec.reactions.all?(&check_that_can) &&
              ext_spec.theres.all?(&check_that_can)

            rd_spec = ext_spec.reduced
            if Chest.has?(rd_spec, method: :full_name)
              rd_spec = Chest.specific_spec(rd_spec.full_name)
            else
              Chest.store(rd_spec, method: :full_name)
            end

            swap_and_store = -> concept do
              concept.swap_source(ext_spec, rd_spec)
              store_concept_to(concept, rd_spec)
            end

            ext_spec.reactions.each(&swap_and_store)
            ext_spec.theres.each(&swap_and_store)

            Chest.purge!(ext_spec, method: :full_name)
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

        # Iterates all reactions
        # @yield [Concepts::UbiquitoursReaction] do for each reaction
        # @return [Enumerator] if block is not given
        def each_reaction(&block)
          reactions = Chest.all(*REACTION_KEYS)
          block_given? ? reactions.each(&block) : reactions.each
        end

        # Gets all typical reactions
        # @param [Array] the array of typical reactions
        def typical_reactions
          Chest.all(:reaction)
        end

        # Gets all lateral reactions
        # @param [Array] the array of lateral reactions
        def lateral_reactions
          Chest.all(:lateral_reaction)
        end

        # Checks type of concept and store it to spec by correspond method
        # @param [concept] concept the checkable concept
        # @param [Spec | SpecificSpec] spec the spec to which concept will be
        #   stored
        # @raise [RuntimeError] if type of concept is undefined
        def store_concept_to(concept, spec)
          if concept.is_a?(Concepts::UbiquitousReaction)
            spec.store_reaction(concept)
          elsif concept.is_a?(Concepts::There)
            spec.store_there(concept)
          else
            raise 'Undefined concept type'
          end
        end
      end
    end

  end
end
