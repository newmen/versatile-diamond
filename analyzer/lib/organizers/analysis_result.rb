module VersatileDiamond
  module Organizers

    # Stores analysis results of some kinetic schema and organizes the
    # relationship between interpreted concepts
    class AnalysisResult
      include SpeciesOrganizer
      include ReactionsOrganizer

      # Exception for case when some reactions overlap
      class ReactionDuplicate < Errors::Base
        attr_reader :first, :second
        # @param [String] first the name of first reaction
        # @param [String] second the name of second reaction
        def initialize(first, second); @first, @second = first, second end
      end

      attr_reader :ubiquitous_reactions, :typical_reactions, :lateral_reactions,
        :theres

      # Collects results of interpretations from Chest to internal storage and
      # organizes dependencies between collected concepts
      def initialize
        @ubiquitous_reactions =
          wrap_reactions(DependentUbiquitousReaction, :ubiquitous_reaction)
        @typical_reactions =
          wrap_reactions(DependentTypicalReaction, :reaction)
        @lateral_reactions =
          wrap_reactions(DependentLateralReaction, :lateral_reaction)

        @theres = collect_theres

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
      # @raise [RuntimeError] if passed klass is not DependentReaction
      # @return [Array] the array with each wrapped reaction
      def wrap_reactions(klass, chest_key)
        raise 'Wrong klass value' unless klass.ancestors.include?(DependentReaction)

        with_rate = Tools::Chest.all(chest_key).reject { |r| r.full_rate == 0 }
        with_rate.map { |reaction| klass.new(reaction) }
      end

      # Collects there instances from lateral reactions
      # @return [Array] the array of collected instances
      def collect_theres
        lateral_reactions.flat_map(&:theres)
      end

      # Collects termination species from reactions
      # @return [Hash] the hash where keys are names of specs and wrapped
      #    termination species as values
      def collect_termination_specs
        ubiquitous_reactions.each_with_object({}) do |reaction, cache|
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
          Chest.all(:gas_spec, :surface_spec).map do |base_spec|
            DependentBaseSpec.new(base_spec)
          end

        make_cache(dependent_bases)
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
        all = [ubiquitous_reactions, typical_reactions, lateral_reactions, theres]
        all.each do |concepts|
          concepts.each do |concept|
            concept.each_source do |specific_spec|
              next if @term_specs[specific_spec.name]

              name = specific_spec.name
              cached_dept_spec = cached_spec(cache, specific_spec)
              if cached_dept_spec
                swap_source_carefully(concept, specific_spec, cached_dept_spec.spec)
              else
                cache[name] = create_dept_specific_spec(specific_spec)
              end

              store_concept_to(concept, cache[name])
            end
          end
        end

        Tools::Config.concs.keys.each do |specific_spec|
          next if cached_spec(cache, specific_spec)
          cache[specific_spec.name] = create_dept_specific_spec(specific_spec)
        end
        cache
      end

      # Finds concept specific spec in cache
      # @param [Hash] cache where will be found similar spec
      # @param [Concepts::SpecificSpec] spec by which the similar spec will be
      #   found in cache
      # @return [DependentSpecificSpec] the search result or nil
      def cached_spec(cache, spec)
        cached_dept_spec = cache[spec.name] || cache.values.find do |dss|
          dss.spec.same?(spec)
        end
      end

      # Creates correspond dependent specific spec instance
      # @param [Concepts::SpecificSpec] spec the concept by which new spec will
      #   created
      # @return [DependentSimpleSpec] the wrapped concept spec
      def create_dept_specific_spec(spec)
        spec.simple? ? DependentSimpleSpec.new(spec) : DependentSpecificSpec.new(spec)
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
        base_specs_cache, specific_specs_cache =
          purge_unused_extended_specs(base_specs_cache, specific_specs_cache)

        unspecified_specs = specific_specs_cache.values.reject(&:specific?)
        unspecified_specs.each do |wrapped_specific|
          wrapped_base = base_specs_cache[wrapped_specific.base_name]
          exchange_specs(specific_specs_cache, wrapped_specific, wrapped_base)
        end

        [base_specs_cache, specific_specs_cache]
      end

      # Organize dependecies between collected items
      # @raise [ReactionDuplicate] if was defined some duplicate of reaction
      def organize_dependecies!
        # order of organization is important!
        organize_spec_dependencies!(@base_specs, specific_specs)

        # before need to update specs by organize their dependecies!
        check_reactions_for_duplicates
        organize_all_reactions_dependencies!
      end

      # Checks stored reactions for duplication with each other
      # @raise [ReactionDuplicate] if duplicate is found
      def check_reactions_for_duplicates
        all = [ubiquitous_reactions, typical_reactions, lateral_reactions]
        all.each do |reactions|
          reactions = reactions.dup

          until reactions.empty?
            reaction = reactions.pop
            same = reactions.find { |r| r != reaction && reaction.same?(r) }
            raise ReactionDuplicate.new(reaction.name, same.name) if same
          end
        end
      end

      # Organize dependencies between all stored reactions.
      # Also organize dependencies between termination species and their complex
      # parents.
      def organize_all_reactions_dependencies!
        nt_spec_cache = @specific_specs.merge(@base_specs)
        reactions_lists = [ubiquitous_reactions, typical_reactions, lateral_reactions]
        organize_reactions_dependencies!(@term_specs, nt_spec_cache, *reactions_lists)
      end
    end

  end
end
