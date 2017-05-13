module VersatileDiamond
  module Organizers
    module Support

      # Provides analysis results instance for RSpec
      module PseudoResults
        include SpeciesOrganizer
        include ReactionsOrganizer

        # The mock of analysis results
        class ResultsMock
          class << self
            def collections(*names)
              names.each do |method_name|
                define_method(method_name) { depts[method_name] }
              end
            end
          end

          collections :base_specs, :specific_specs
          collections :ubiquitous_reactions, :typical_reactions, :lateral_reactions

          def initialize(depts)
            @depts = depts
          end

        private

          attr_reader :depts

        end

        # Stubs analysis results and allow to call methods with same names as keys of
        # passed hash
        #
        # @param [Hash] depts see at #stub_generator same argument
        # @return [RSpec::Mocks::Double] same as original analysis results
        def stub_results(**depts)
          ChunkLinksMerger.init_veiled_cache!
          if depts[:typical_reactions]
            reorganize_children_specs!(depts[:typical_reactions].map(&:reaction))
          end

          fixed_depts =
            fix(depts).each_with_object({}) do |(method_name, list), acc|
              acc[method_name] = list
            end

          mocking_depts =
            sort_depts(fixed_depts).each_with_object({}) do |(method_name, list), acc|
              if organization_keys.include?(method_name)
                orgres = send(:"organize_#{method_name}", fixed_depts)
                list += orgres if method_name == :lateral_reactions
              end

              acc[method_name] = list
            end

          ResultsMock.new(mocking_depts)
        end

      private

        # The list of methods which data could be organized. Should be correspond to
        # methods which described at end of current module
        #
        # @return [Set] the list of method names which data could be organized
        def organization_keys
          Set[
            :base_specs, :specific_specs,
            :ubiquitous_reactions, :typical_reactions, :lateral_reactions
          ]
        end

        # Provides default keys (names of analysis result methods)
        # @return [Array] the list of default keys
        def default_keys
          [
            :base_specs, :specific_specs, :term_specs,
            :ubiquitous_reactions, :typical_reactions, :lateral_reactions
          ]
        end

        # Extends passed depts for analysis result methods
        # @return [Hash] the hash where each not presented value is empty array
        def merge_with_default(depts)
          default_keys.each_with_object({}) do |key, acc|
            presented_values = depts[key]
            acc[key] = presented_values ? presented_values.dup : []
          end
        end

        # Sorts in order of default depts keys
        # @return [Array] the array of sorted pairs
        def sort_depts(depts)
          depts.sort_by { |k, _| default_keys.index(k) }
        end

        # Extends passed depts hash by adding all internal species
        # @return [Hash] the fixed cache of depts
        def fix(depts)
          ordered_depts = sort_depts(merge_with_default(depts))
          only_specs = ordered_depts.flat_map(&:last).select do |o|
            o.is_a?(DependentSimpleSpec)
          end

          all_specs = Hash[only_specs.map { |ds| [ds.name, ds] }]
          depts_cache = Hash[ordered_depts]

          fix_reactants(depts_cache, all_specs)

          purging_specs = [depts_cache[:base_specs], depts_cache[:specific_specs]]
          pss = purge_unused_extended_specs(*purging_specs.map(&method(:make_cache)))
          depts_cache[:base_specs], depts_cache[:specific_specs] = pss.map(&:values)

          fix_sidepieces(depts_cache, all_specs)
          fix_bases(depts_cache, all_specs)
          fix_same_bases(depts_cache[:specific_specs])

          depts_cache
        end

        # Gets correct dependent spec from cache
        def spec_from(cache, spec)
          cache[spec.name] || cache[spec.spec.name]
        end

        # Extends passed variables by reactant specs
        def fix_reactants(depts_cache, all_specs)
          [:ubiquitous_reactions, :typical_reactions, :lateral_reactions].each do |k|
            depts_cache[k].each do |dr|
              [:source, :products].each do |target|
                dr.reaction.each(target) do |s|
                  if all_specs.include?(s.name)
                    swap_carefully(target, dr, s, spec_from(all_specs, s).spec)
                  else
                    if s.termination?
                      dt = DependentTermination.new(s)
                      depts_cache[:term_specs] << dt
                      all_specs[dt.name] = dt
                    else
                      store_reactant(dr, depts_cache, all_specs, s)
                    end
                  end

                  store_concept_to(dr, spec_from(all_specs, s))
                end
              end
            end
          end
        end

        # Extends passed variables by sidepieces from where objects
        def fix_sidepieces(depts_cache, all_specs)
          depts_cache[:lateral_reactions].each do |reaction|
            reaction.theres.each do |there|
              [:source, :products].each do |target|
                there.each(target) do |s|
                  if all_specs.include?(s.name)
                    swap_carefully(target, there, s, spec_from(all_specs, s).spec)
                  else
                    store_reactant(there, depts_cache, all_specs, s)
                  end

                  store_concept_to(there, spec_from(all_specs, s)) if target == :source
                end
              end
            end
          end
        end

        # Extends passed variables by base specs from specific specs
        def fix_bases(depts_cache, all_specs)
          depts_cache[:specific_specs].each do |ds|
            next if all_specs.include?(ds.spec.spec.name)
            ds = DependentBaseSpec.new(ds.spec.spec)
            depts_cache[:base_specs] << ds
            all_specs[ds.name] = ds
          end
        end

        # Checks that if some reaction contains specific spec and same base spec then
        # base spec will be swapped to veiled spec
        def fix_same_bases(specific_specs)
          exchange_same_used_base_specs_of(specific_specs)
        end

        # Provides lambda which checks type of own argument and wraps and store it
        # to passed variables
        def store_reactant(dcont, depts_cache, all_specs, spec)
          if spec.is_a?(Concepts::SpecificSpec)

            ds = spec.simple? ?
              DependentSimpleSpec.new(spec) :
              DependentSpecificSpec.new(spec)

            if ds.simple? || ds.specific?
              depts_cache[:specific_specs] << ds
              all_specs[ds.name] = ds
            else
              dbs = depts_cache[:base_specs].find { |bs| bs.name == spec.spec.name }
              dbs ||= DependentBaseSpec.new(spec.spec)
              [:source, :products].each do |target|
                swap_carefully(target, dcont, spec, dbs.spec)
              end
              unless all_specs.include?(dbs.name)
                depts_cache[:base_specs] << dbs
                all_specs[dbs.name] = dbs
              end
            end
          elsif spec.is_a?(Concepts::Spec)
            dbs = DependentBaseSpec.new(spec)
            depts_cache[:base_specs] << dbs
            all_specs[spec.name] = dbs
          else
            raise 'So strange reactant'
          end
        end

        # Organizes dependencies between wrapped base species
        def organize_base_specs(depts)
          organize_base_specs_dependencies!(depts[:base_specs])
        end

        # Organizes dependencies between wrapped specific species
        def organize_specific_specs(depts)
          base_cache = make_cache(depts[:base_specs])
          not_simple_specs = depts[:specific_specs].reject(&:simple?)
          organize_specific_specs_dependencies!(base_cache, not_simple_specs)
        end

        # Organizes dependencies between wrapped ubiquitous reactions
        def organize_ubiquitous_reactions(depts)
          term_ss = make_cache(depts[:term_specs])
          non_term_ss = make_cache(depts[:base_specs])
          non_term_ss = non_term_ss.merge(make_cache(depts[:specific_specs]))
          reactions_lists = [
            depts[:ubiquitous_reactions],
            depts[:typical_reactions],
            depts[:lateral_reactions]
          ]

          organize_ubiquitous_reactions_deps!(term_ss, non_term_ss, *reactions_lists)
        end

        # Organizes dependencies between typical reactions
        def organize_typical_reactions(depts)
          return @_combined_reactions if @_combined_reactions
          reactions_lists = [depts[:typical_reactions], depts[:lateral_reactions]]
          @_combined_reactions = organize_complex_reactions_deps!(*reactions_lists)
        end

        # Organizes dependencies between lateral reactions
        def organize_lateral_reactions(depts)
          organize_typical_reactions(depts)
        end
      end
    end
  end
end
