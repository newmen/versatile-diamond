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
        organize_specific_spec_dependencies!(base_cache, specific_specs)
        purge_same_base_specs!(base_cache, specific_specs)
        organize_base_specs_dependencies!(base_cache.values)
        purge_unused_base_specs!(base_cache)
      end

    private
      # Organize dependencies between specific species
      # @param [Hash] base_cache see at #organize_spec_dependencies! same argument
      # @param [Array] specific_specs see at #organize_spec_dependencies! same argument
      def organize_specific_spec_dependencies!(base_cache, specific_specs)
        specific_specs.each_with_object({}) do |wrapped_specific, specs|
          base_name = wrapped_specific.base_name
          specs[base_name] ||= specific_specs.select do |s|
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
              if wrapped_specific.parent && wrapped_specific.parent.name == same_name
                wrapped_specific.replace_parent(wrapped_base)
              end
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
