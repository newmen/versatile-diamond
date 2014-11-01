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

      # Gets all collected reactions with complex surface species
      # @return [Array] the array of arrays of reactions
      def spec_reactions
        [typical_reactions, lateral_reactions]
      end

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
        lateral_reactions.reduce([]) { |acc, reaction| acc + reaction.theres }
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
        (spec_reactions + [theres]).each_with_object({}) do |concepts, cache|
          concepts.each do |concept|
            concept.each_source do |specific_spec|
              name = specific_spec.name
              cached_dept_spec = cache[name] || cache.values.find do |dss|
                dss.spec.same?(specific_spec)
              end

              if cached_dept_spec
                concept.swap_source(specific_spec, cached_dept_spec.spec)
              else
                cache[name] = DependentSpecificSpec.new(specific_spec)
              end

              store_concept_to(concept, cache[name])
            end
          end
        end
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
      # @param [Hash] base_specs_cache the cache of base speces where keys are
      #   names of specs and values are wrapped base specs
      # @param [Hash] specific_specs_cache the cache of specific specs where
      #   keys is full names of specs
      # @return [Hash] resulted cache of specific specs
      def purge_unused_extended_specs(base_specs_cache, specific_specs_cache)
        extended_specs = specific_specs_cache.select do |_, spec|
          spec.could_be_reduced?
        end

        extended_specs.each do |_, wrapped_ext|
          check_that_can = -> wrapped_concept do
            concept_spec = wrapped_ext.spec
            used_atoms = wrapped_concept.used_atoms_of(concept_spec)
            used_keynames = used_atoms.map { |a| concept_spec.keyname(a) }
            Concepts::Spec.good_for_reduce?(used_keynames)
          end

          next unless wrapped_ext.reactions.all?(&check_that_can) &&
            wrapped_ext.theres.all?(&check_that_can)

          rd_spec = wrapped_ext.reduced
          wrapped_rd =
            specific_specs_cache[rd_spec.name] ||= DependentSpecificSpec.new(rd_spec)

          exchange_specs(specific_specs_cache, wrapped_ext, wrapped_rd)
          base_specs_cache.delete(wrapped_ext.base_name)
        end

        [base_specs_cache, specific_specs_cache]
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
        ([ubiquitous_reactions] + spec_reactions).each do |reactions|
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
