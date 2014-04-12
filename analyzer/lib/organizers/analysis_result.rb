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
        @ubiquitous_reactions =
          wrap_reactions(DependentUbiquitousReaction, :ubiquitous_reaction)
        @typical_reactions =
          wrap_reactions(DependentTypicalReaction, :reaction)
        @lateral_reactions =
          wrap_reactions(DependentLateralReaction, :lateral_reaction)

        @term_specs = collect_termination_specs
        @base_specs, @specific_specs =
          purge_unspecified_specs(collect_base_specs, collect_specific_specs)

        organize_dependecies!
      end

      %w(term base specific).each do |type|
        var = :"@#{type}_specs"

        # Gets an wrapped instance by name
        # @param [Symbol] name the name of selecting spec
        # @return [DependentSpec] the dependent instance
        define_method(:"#{type}_spec") do |name|
          instance_variable_get(var)[name]
        end

        # Gets wrapped instances
        # @return [Array] the array of dependent instance
        define_method(:"#{type}_specs") do
          instance_variable_get(var).values
        end
      end

    private

      # Wraps reactions from Chest
      # @param [Class] the class that inherits DependentReaction
      # @param [Symbol] chest_key the key by which reactions will be got from Chest
      # @return [Array] the array with each wrapped reaction
      def wrap_reactions(klass, chest_key)
        raise 'Wrong klass value' unless klass.ancestors.include?(DependentReaction)

        with_rate = Tools::Chest.all(chest_key).reject { |r| r.full_rate == 0 }
        with_rate.map { |reaction| klass.new(reaction) }
      end

      # Gets all collected reactions with complex surface species
      # @return [Array] the array of arrays of reactions
      def spec_reactions
        [typical_reactions, lateral_reactions]
      end

      # Collects termination species from reactions
      # @return [Hash] the hash where keys are names of specs and wrapped
      #    termination species as values
      def collect_termination_specs
        ubiquitous_reactions.each.with_object({}) do |reaction, cache|
          term = reaction.termination
          cache[term.name] ||= DependentTermination.new(term)
          store_concept_to(reaction, cache[term.name])
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
      # looked around by atom mapping! At collecting time swaps reaction source
      # spec with another same spec (with same name) if it another spec already
      # collected. Each specific spec stores reaction or theres from which it
      # dependent.
      #
      # @return [Hash] the hash of collected specific species where keys are
      #   full names of each specific spec
      def collect_specific_specs
        cache = {}
        store_lambda = -> concept do
          -> specific_spec do
            name = specific_spec.name
            if cache[name]
              concept.swap_source(specific_spec, cache[name].spec)
            else
              cache[name] = DependentSpecificSpec.new(specific_spec)
            end

            store_concept_to(concept, cache[name])
          end
        end

        spec_reactions.each do |concrete_reactions|
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
      # @raise [ArgumentError] if type of concept is undefined
      def store_concept_to(wrapped_concept, wrapped_spec)
        if wrapped_concept.is_a?(DependentReaction)
          wrapped_spec.store_reaction(wrapped_concept)
        elsif wrapped_concept.is_a?(DependentThere)
          wrapped_spec.store_there(wrapped_concept)
        else
          raise ArgumentError, 'Undefined concept type'
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
            specific_specs_cache[rd_spec.name] ||= DependentSpecificSpec.new(rd_spec)

          exchange_specs(specific_specs_cache, wrapped_ext, wrapped_rd)
        end

        specific_specs_cache
      end

      # Purges all specific specs if some of doesn't have specific atoms and
      # reactions
      #
      # @param [Hash] base_specs_cache the cache of base speces where keys are
      #   names of specs and values are wrapped base specs
      # @param [Hash] specific_specs_cache the cache of specific specs where
      #   keys are full names of specs and values are wrapped specific specs
      # @return [Array] the array where first item is base specs hash and
      #   second item is specific specs hash
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

        purge_same_base_specs(base_specs_cache, specific_specs_cache)
      end

      # Purges same base specs if they exists, as replacing duplicated base
      # spec in correspond specific spec and their reactions and theres
      #
      # @param [Hash] base_specs_cache see at #purge_unspecifified_specs same
      #   argument
      # @param [Hash] specific_specs_cache see at #purge_unspecifified_specs
      #   same argument
      # @return [Array] see at result of #purge_unspecifified_specs
      def purge_same_base_specs(base_specs_cache, specific_specs_cache)
        wrapped_base_specs = base_specs_cache.values
        wrapped_specific_specs = specific_specs_cache.values

        until wrapped_base_specs.empty?
          wrapped_base = wrapped_base_specs.pop

          sames = wrapped_base_specs.select do |wbs|
            wbs.name != wrapped_base.name && wrapped_base.same?(wbs)
          end

          wrapped_base_specs -= sames

          sames.each do |same_base|
            exchange_specs(base_specs_cache, same_base, wrapped_base)

            same_name = same_base.name
            wrapped_specific_specs.each do |wrapped_specific|
              if wrapped_specific.base_name == same_name
                wrapped_specific.replace_base_spec(wrapped_base.spec)
              end
            end
          end
        end

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
        check_reactions_for_duplicates
        organize_reactions_dependencies!

        organize_specs_dependencies!
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

      # Checks stored reactions for duplication with each other
      # @raise [ReactionDuplicate] if duplicate is found
      def check_reactions_for_duplicates
        ([ubiquitous_reactions] + spec_reactions).each do |reactions|
          reactions = reactions.dup

          until reactions.empty?
            reaction = reactions.pop
            same = reactions.find { |r| r != reaction && reaction.same?(r) }
            raise ReactionDuplicate.new(reaction.name, same.name) if same
          end
        end
      end

      # Organize dependencies between all stored reactions
      def organize_reactions_dependencies!
        cached_spec_reactions = spec_reactions.flatten
        # order of dependencies organization is important!
        ubiquitous_reactions.each do |reaction|
          reaction.organize_dependencies!(cached_spec_reactions)
        end
        lateral_reactions.each do |reaction|
          reaction.organize_dependencies!(lateral_reactions)
        end
        typical_reactions.each do |reaction|
          reaction.organize_dependencies!(lateral_reactions)
        end
      end

      # Organize dependencies between base specs
      def organize_specs_dependencies!
        table = BaseSpeciesTable.new(base_specs)
        base_specs.each do |wrapped_base|
          wrapped_base.organize_dependencies!(table)
        end
      end












      # # Removes all unused base specs from Chest
      # def purge_unused_specs!
      #   purge_excess_extrime_specs!

      #   specs = Chest.all(:gas_spec, :surface_spec)
      #   specific_specs = Chest.all(:specific_spec)

      #   specs.each do |spec|
      #     has_parent = specs.any? { |s| s.parent == spec }
      #     has_children = has_parent || specific_specs.any? do |specific_spec|
      #       specific_spec.spec == spec
      #     end

      #     Chest.purge!(spec) unless has_children
      #   end
      # end















      # Purges all extrime base spec if some have just one child and it
      # child is unspecified specific spec
      def purge_excess_extrime_specs!
        base_specs.each do |wrapped_base|

        end




        unspecified_specs = Chest.all(:specific_spec).select do |spec|
          !spec.specific? && !spec.parent
        end

        unspecified_specs.each do |specific_spec|
          base_spec = specific_spec.spec
          next unless base_spec.childs.size == 1 && base_spec.theres.empty?

          base_parent = base_spec.parent
          next unless base_parent

          specific_spec.replace_base_spec(base_parent)
          base_parent.remove_child(base_spec)
          base_parent.store_child(specific_spec)

          Chest.purge!(base_spec)
        end
      end
    end

  end
end
