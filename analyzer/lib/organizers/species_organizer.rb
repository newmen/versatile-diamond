module VersatileDiamond
  module Organizers

    # Provides methods for base and specieic species organization
    module SpeciesOrganizer

      # Makes the hash where keys are names of passed species
      # @param [Array] specs the array of species by which cache will be created
      # @return [Hash] the cache
      def make_cache(specs)
        Hash[specs.map(&:name).zip(specs)]
      end

      # Organize dependencies between passed species
      #
      # @param [Hash] base_cache the hash of base species dependencies between
      #   which will be organized where keys are names of correspond species
      # @param [Array] specific_specs the array of specific species dependencies
      #   between which will be organized
      def organize_spec_dependencies!(base_cache, specific_specs)
        # order of organization is important!
        purge_same_base_specs!(base_cache, specific_specs)
        organize_specific_specs_dependencies!(base_cache, specific_specs)
        organize_base_specs_dependencies!(base_cache.values)
        purge_unused_base_specs!(base_cache)
      end

    private

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

      # Checks that swapping source presented in target container and if so then
      # wraps new source spec to veiled spec
      #
      # @param [DependentReaction | DependentThere] target_container in which the
      #   source spec will be changed
      # @param [Concepts::Spec | Concepts::SpecificSpec] from the source spec which
      #   will be changed
      # @param [Concepts::Spec | Concepts::SpecificSpec] to the new spec to which
      #   old spec will be changed
      def swap_source_carefully(target_container, from, to)
        return if from == to
        has_similar_spec = target_container.use_similar_source?(to)
        to_spec = has_similar_spec ? Concepts::VeiledSpec.new(to) : to
        target_container.swap_source(from, to_spec)
      end

      # Excnahges two specs
      # @param [DependentSpecificSpec | DependentSpecificSpec] from the spec
      #   which will be exchanged
      # @param [DependentSpecificSpec | DependentSpec] to the spec to which
      #   will be exchanged
      # @param [Hash] cache where contains pairs of name => dependent_spec
      def exchange_specs(cache, from, to)
        lambda = -> wrapped_concept do
          wrapped_concept.each_source.each do |spec|
            if spec.name == from.spec.name
              swap_source_carefully(wrapped_concept, spec, to.spec)
            end
          end
          store_concept_to(wrapped_concept, to)
        end

        from.reactions.each(&lambda)
        from.theres.each(&lambda)

        cache.delete(from.name)
      end

      # Purges extended spec if atoms of each one can be used as same in
      # reduced spec
      #
      # @param [Hash] base_specs_cache the cache of base speces where keys are
      #   names of specs and values are wrapped base specs
      # @param [Hash] specific_specs_cache the cache of specific specs where
      #   keys is full names of specs
      # @return [Array] purged caches of specs
      def purge_unused_extended_specs(base_specs_cache, specific_specs_cache)
        extended_specs = specific_specs_cache.select do |_, spec|
          !spec.simple? && spec.could_be_reduced?
        end

        extended_specs.each do |_, wrapped_ext|
          check_that_can = -> wrapped_concept do
            used_atoms = wrapped_concept.used_atoms_of(wrapped_ext)
            used_keynames = used_atoms.map { |a| wrapped_ext.spec.keyname(a) }
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

      # Organize dependencies between specific species
      # @param [Hash] base_cache see at #organize_spec_dependencies! same argument
      # @param [Array] specific_specs see at #organize_spec_dependencies! same argument
      def organize_specific_specs_dependencies!(base_cache, specific_specs)
        not_simple_specs = specific_specs.reject(&:simple?)
        not_simple_specs.each_with_object({}) do |wrapped_specific, specs|
          base_name = wrapped_specific.base_name
          specs[base_name] ||= not_simple_specs.select do |s|
            s.base_name == base_name
          end

          wrapped_specific.organize_dependencies!(base_cache, specs[base_name])
        end
      end

      # Purges same base specs if they exists, as replacing duplicated base
      # spec in correspond specific spec and their reactions and theres
      #
      # @param [Hash] base_cache see at #organize_spec_dependencies! same argument
      # @param [Array] specific_specs see at #organize_spec_dependencies! same argument
      def purge_same_base_specs!(base_cache, specific_specs)
        wrapped_base_specs = base_cache.values

        until wrapped_base_specs.empty?
          wrapped_base = wrapped_base_specs.pop

          sames = wrapped_base_specs.select do |wbs|
            wbs.name != wrapped_base.name && wrapped_base.same?(wbs)
          end

          wrapped_base_specs -= sames

          sames.each do |same_base|
            exchange_specs(@base_specs, same_base, wrapped_base)

            same_name = same_base.name
            specific_specs.each do |wrapped_specific|
              next unless wrapped_specific.base_name == same_name
              wrapped_specific.replace_base_spec(wrapped_base)
            end

            base_cache.delete(same_base.name)
          end
        end
      end

      # Organize dependencies between base specs
      # @param [Array] base_specs array of base species the dependencies between
      #   which will be organized
      def organize_base_specs_dependencies!(base_specs)
        table = BaseSpeciesTable.new(base_specs)
        base_specs.each do |wrapped_base|
          wrapped_base.organize_dependencies!(table)
        end
      end

      # Removes all unused base specs
      # @param [Hash] base_cache see at #organize_spec_dependencies! same argument
      def purge_unused_base_specs!(base_cache)
        loop do
          have_excess = purge_base_specs!(base_cache, :excess?)
          have_unused = purge_base_specs!(base_cache, :unused?)
          break if !have_excess && !have_unused
        end
      end

      # Purges all extrime base spec if some have just one child and it
      # child is unspecified specific spec
      #
      # @param [Hash] base_cache see at #organize_spec_dependencies! same argument
      # @param [Symbol] check_method_name the method by which purging species will be
      #   selected
      # @return [Boolean] have purged species or not
      def purge_base_specs!(base_cache, check_method_name)
        purging_specs = base_cache.values.select(&check_method_name)
        purging_specs.each do |purging_spec|
          purging_spec.exclude
          base_cache.delete(purging_spec.name)
        end
        !purging_specs.empty?
      end
    end

  end
end
