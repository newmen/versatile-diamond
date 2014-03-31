module VersatileDiamond
  module Organizers

    # Stores analysis results of some kinetic schema and organizes the
    # relationship between interpreted concepts
    class AnalysisResult

      # Exception for case when some reactions overlap
      class ReactionDuplicate < Errors::Base
        attr_reader :first, :second
        # @param [String] first the name of first reaction
        # @param [String] second the name of second reaction
        def initialize(first, second); @first, @second = first, second end
      end

      attr_reader :ubiquitous_reactions, :typical_reactions, :lateral_reactions

      # Collects results of interpretations from Chest to internal storage and
      # organizes dependencies between collected concepts
      def initialize
        @ubiquitous_reactions = wrap_reactions(:ubiquitous_reaction)
        @typical_reactions = wrap_reactions(:reaction)
        @lateral_reactions = wrap_reactions(:lateral_reaction)

        @term_specs = collect_termination_specs
        @base_specs, @specific_specs =
          purge_unspecified_specs(collect_base_specs, collect_specific_specs)

        organize_dependecies!
      end

      %w(term base specific).each do |type|
        var = :"@#{type}_specs"

        define_method(:"#{type}_spec") do |name|
          instance_variable_get(var)[name]
        end

        define_method(:"#{type}_specs") do
          instance_variable_get(var).values
        end
      end

    private

      # Wraps reactions from Chest
      # @param [Symbol] reactions_key the key by which reactions will be got
      #   from Chest
      # @return [Array] the array with each wrapped reaction
      def wrap_reactions(reactions_key)
        with_rate = Chest.all(reactions_key).reject { |r| r.full_rate == 0 }
        with_rate.map { |reaction| DependentReaction.new(reaction) }
      end

      # Gets all collected reactions
      # @return [Array] the array of arrays of reactions
      def reactions
        [typical_reactions, lateral_reactions]
      end

      # Collects termination species from reactions
      # @return [Hash] the hash where keys are names of specs and wrapped
      #    termination species as values
      def collect_termination_specs
        ubiquitous_reactions.each.with_object({}) do |reaction, cache|
          reaction.each_source do |spec|
            cache[spec.name] ||= DependentTermination.new(spec)
            store_concept_to(reaction, cache[spec.name])
          end
        end
      end

      # Collects base spec from Chest and each one
      # @return [Hash] the hash of collected base species where keys are names
      #   of each base spec
      def collect_base_specs
        dependent_bases =
          Chest.all(:surface_spec).map do |base_spec|
            DependentBaseSpec.new(base_spec)
          end

        Hash[dependent_bases.map(&:name).zip(dependent_bases)]
      end

      # Collects specific species from all reactions. Each spec must be already
      # looked around! At collecting time swaps reaction source spec with
      # another same spec (with same name) if it another spec already
      # collected. Each specific spec stores reaction or theres from which it
      # dependent.
      #
      # @return [Hash] the hash of collected specific species where keys are
      #   full names of each specific spec
      def collect_specific_specs
        cache = {}
        store_lambda = -> concept do
          -> specific_spec do
            full_name = specific_spec.full_name
            if cache[full_name]
              concept.swap_source(specific_spec, cache[full_name].spec)
            else
              cache[full_name] = DependentSpecificSpec.new(specific_spec)
            end

            store_concept_to(concept, cache[full_name])
          end
        end

        reactions.each do |concrete_reactions|
          concrete_reactions.each do |reaction|
            reaction.each_source(&store_lambda[reaction])
          end
        end

        lateral_reactions.each do |reaction|
          reaction.theres.each do |there|
            there.env_specs.each(&store_lambda[there])
          end
        end

        purge_unused_extended_specs(cache)
      end

      # Checks type of concept and store it to spec by correspond method
      # @param [DependentReaction | DependentThere] wrapped_concept the
      #   checkable and storable concept
      # @param [DependentSpec | DependentSpecificSpec] wrapped_spec the wrapped
      #   spec to which concept will be stored
      # @raise [RuntimeError] if type of concept is undefined
      def store_concept_to(wrapped_concept, wrapped_spec)
        if wrapped_concept.is_a?(DependentReaction)
          wrapped_spec.store_reaction(wrapped_concept)
        elsif wrapped_concept.is_a?(DependentThere)
          wrapped_spec.store_there(wrapped_concept)
        else
          raise 'Undefined concept type'
        end
      end

      # Purges extended spec if atoms of each one can be used as same in
      # reduced spec
      #
      # @param [Hash] specific_specs_cache the cache of specific specs where
      #   keys is full names of specs
      # @return [Hash] resulted cache of specific specs
      def purge_unused_extended_specs(specific_specs_cache)
        extended_specs = specific_specs_cache.select do |_, spec|
          spec.reduced && spec.could_be_reduced?
        end

        extended_specs.each do |_, wrapped_ext|
          check_that_can = -> wrapped_concept do
            used_keynames = wrapped_concept.used_keynames_of(wrapped_ext.spec)
            Concepts::Spec.good_for_reduce?(used_keynames)
          end

          next unless wrapped_ext.reactions.all?(&check_that_can) &&
            wrapped_ext.theres.all?(&check_that_can)

          rd_spec = wrapped_ext.reduced
          wrapped_rd =
            specific_specs_cache[rd_spec.full_name] ||=
              DependentSpecificSpec.new(rd_spec)

          exchange_specs(specific_specs_cache, wrapped_ext, wrapped_rd)
        end

        specific_specs_cache
      end

      # Purges all specific specs if some of doesn't have specific atoms and
      # reactions
      #
      # @param [Hash] specific_specs_cache the cache of specific specs where
      #   keys is full names of specs
      # @return [Hash] resulted cache of specific specs
      def purge_unspecified_specs(base_specs_cache, specific_specs_cache)
        unspecified_specs = specific_specs_cache.values.reject(&:specific?)

        store_lambda = -> wrapped_specific do
          spec = wrapped_specific.base_spec
          base_specs_cache[spec.name] ||= DependentBaseSpec.new(spec)
        end

        unspecified_specs.each do |wrapped_specific|
          wrapped_base = store_lambda[wrapped_specific]
          exchange_specs(specific_specs_cache, wrapped_specific, wrapped_base)
        end

        specified_specs = specific_specs_cache.values - unspecified_specs
        specified_specs.each(&store_lambda)

        [base_specs_cache, specific_specs_cache]
      end

      # Excnahges two specs
      # @param [DependentSpecificSpec | DependentSpecificSpec] from the spec
      #   which will be exchanged
      # @param [DependentSpecificSpec | DependentSpec] to the spec to which
      #   will be exchanged
      # @param [Hash] cache where contains pairs of name => dependent_spec
      def exchange_specs(cache, from, to)
        lambda = -> wrapped_concept do
          wrapped_concept.swap_source(from.spec, to.spec)
          store_concept_to(wrapped_concept, to)
        end

        from.reactions.each(&lambda)
        from.theres.each(&lambda)

        cache.delete(from.name)
      end

      # Organize dependecies between concepts stored in Chest
      # @raise [ReactionDuplicate] if was defined some duplicate of reaction
      def organize_dependecies!
        # order of organization is important!
        organize_specific_spec_dependencies!

        # before need to update specs by organize their dependecies!
        # check_reactions_for_duplicates
        # organize_reactions_dependencies!

        # organize_specs_dependencies!
        # purge_unused_specs!
      end

      # Organize dependencies between specific species
      def organize_specific_spec_dependencies!
        specific_specs.each_with_object({}) do |wss, specs|
          base_name = wss.base_name
          specs[base_name] ||= specific_specs.select do |s|
            s.base_name == base_name
          end

          wss.organize_dependencies!(@base_specs, specs[base_name])
        end
      end
















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
