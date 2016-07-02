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

      attr_reader :ubiquitous_reactions, :typical_reactions, :lateral_reactions

      # Collects results of interpretations from Chest to internal storage and
      # organizes dependencies between collected concepts
      def initialize
        ChunkLinksMerger.init_veiled_cache!
        reorganize_children_specs!(Tools::Chest.all(:reaction))

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

        exchange_same_used_base_specs!
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

      attr_reader :theres

      # Grabs possible reactions from Chest by passed key
      # @param [Symbol] chest_key the key by which reactions will be got from Chest
      # @return [Array] the list of significant reactions
      def significant_reactions(chest_key)
        Tools::Chest.all(chest_key).select(&:significant?)
      end

      # Wraps reactions from Chest
      # @param [Class] the class that inherits DependentReaction
      # @param [Symbol] chest_key the key by which reactions will be got from Chest
      # @raise [RuntimeError] if passed klass is not DependentReaction
      # @return [Array] the array with each wrapped reaction
      def wrap_reactions(klass, chest_key)
        significant_reactions(chest_key).map { |reaction| klass.new(reaction) }
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
        concepts = Tools::Chest.all(:gas_spec, :surface_spec)
        dependent_bases = concepts.map(&method(:create_dept_base_spec))
        make_cache(dependent_bases)
      end

      # Collects specific species from all reactions. Each spec must be already
      # looked around by atom mapping! At collecting time swaps reaction source
      # spec with another same spec (with same name) if it another spec already
      # collected. Each specific spec stores reaction or theres from which it
      #

      # @return [Hash] the hash of collected specific species where keys are
      #   full names of each specific spec
      def collect_specific_specs
        cache = {}
        (all_reactions + [theres]).each do |dept_concepts|
          dept_concepts.each do |dept_concept|
            is_ubiquitous = ubiquitous_reactions.include?(dept_concept)
            [:source, :products].each do |target|
              dept_concept.each(target) do |spec|
                next if is_ubiquitous && !spec.simple?
                name = spec.name

                cached_dept_spec = cached_spec(cache, spec)
                if cached_dept_spec
                  cached_conc_spec = cached_dept_spec.spec
                  name = cached_conc_spec.name
                  swap_carefully(target, dept_concept, spec, cached_conc_spec)
                else
                  cache[name] = create_dept_specific_spec(spec)
                end

                store_concept_to(dept_concept, cache[name])
              end
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
        cached_dept_spec = cache[spec.name]
        if cached_dept_spec
          cached_dept_spec
        else
          similar_dept_spec = cache.values.find { |dss| dss.spec.same?(spec) }
          cache[similar_dept_spec.name] = similar_dept_spec if similar_dept_spec
          similar_dept_spec
        end
      end

      # Creates correspond dependent base spec instance
      # @param [Concepts::Spec] spec the concept by which new spec will created
      # @return [DependentSimpleSpec | DependentBaseSpec] the wrapped concept spec
      def create_dept_base_spec(spec)
        spec.simple? ? DependentSimpleSpec.new(spec) : DependentBaseSpec.new(spec)
      end

      # Creates correspond dependent specific spec instance
      # @param [Concepts::SpecificSpec] spec concept by which new spec will created
      # @return [DependentSimpleSpec | DependentSpecificSpec] the wrapped concept spec
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

      # Checks that if some reaction contains specific spec and same base spec then
      # base spec will be swapped to veiled spec
      def exchange_same_used_base_specs!
        exchange_same_used_base_specs_of(specific_specs.reject(&:simple?))
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
        all_reactions.each do |reactions|
          reactions = reactions.dup
          until reactions.empty?
            reaction = reactions.pop
            same = reactions.find { |r| r != reaction && reaction.same?(r) }
            raise ReactionDuplicate.new(reaction.name, same.name) if same
          end
        end
      end

      # Gets lists of all types reactoins
      # @return [Array] the lists of reactions
      def all_reactions
        [ubiquitous_reactions, typical_reactions, lateral_reactions]
      end

      # Organize dependencies between all stored reactions.
      # Also organize dependencies between termination species and their complex
      # parents.
      # The lateral reactions which was missed by user and which could be is combined.
      # Combined lateral reactions extends initial list of lateral reactions.
      def organize_all_reactions_dependencies!
        nt_spec_cache = @specific_specs.merge(@base_specs)
        combined_lateral_reactions =
          organize_reactions_dependencies!(@term_specs, nt_spec_cache, *all_reactions)

        @lateral_reactions += combined_lateral_reactions
      end
    end

  end
end
