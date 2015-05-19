module VersatileDiamond
  module Organizers
    module Support

      # Provides analysis results instance for RSpec
      module PseudoResults
        include SpeciesOrganizer
        include ReactionsOrganizer

        # Stubs analysis results and allow to call methods with same names as keys of
        # passed hash
        #
        # @param [Hash] depts see at #stub_generator same argument
        # @return [RSpec::Mocks::Double] same as original analysis results
        def stub_results(**depts)
          results = double('pseudo_analysis_results')
          fix(depts).each do |method_name, list|
            allow(results).to receive(method_name).and_return(list)
          end

          sort_depts(depts).each do |method_name, list|
            send(:"organize_#{method_name}", results) unless list.empty?
          end

          results
        end

      private

        # Provides default keys (names of analysis result methods)
        # @return [Array] the list of default keys
        def default_keys
          [
            :base_specs, :specific_specs, :term_specs,
            :ubiquitous_reactions, :lateral_reactions, :typical_reactions
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
              dr.reaction.each_source do |s|
                if all_specs.include?(s.name)
                  swap_source_carefully(dr, s, spec_from(all_specs, s).spec)
                else
                  if s.is_a?(Concepts::TerminationSpec)
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

        # Extends passed variables by sidepieces from where objects
        def fix_sidepieces(depts_cache, all_specs)
          depts_cache[:lateral_reactions].each do |reaction|
            reaction.theres.each do |th|
              there = DependentThere.new(reaction, th)
              there.where.specs.each do |s|
                if all_specs.include?(s.name)
                  swap_source_carefully(there, s, spec_from(all_specs, s).spec)
                else
                  store_reactant(there, depts_cache, all_specs, s)
                end

                store_concept_to(there, spec_from(all_specs, s))
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
              swap_source_carefully(dcont, spec, dbs.spec)
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
        def organize_base_specs(res)
          organize_base_specs_dependencies!(res.base_specs)
        end

        # Organizes dependencies between wrapped specific species
        def organize_specific_specs(res)
          base_cache = make_cache(res.base_specs)
          not_simple_specs = res.specific_specs.reject(&:simple?)
          organize_specific_specs_dependencies!(base_cache, not_simple_specs)
        end

        # Organizes dependencies between wrapped ubiquitous reactions
        def organize_ubiquitous_reactions(res)
          term_ss = make_cache(res.term_specs)
          non_term_ss = make_cache(res.base_specs)
          non_term_ss = non_term_ss.merge(make_cache(res.specific_specs))
          reactions_lists = [
            res.ubiquitous_reactions, res.typical_reactions, res.lateral_reactions
          ]

          organize_ubiquitous_reactions_deps!(term_ss, non_term_ss, *reactions_lists)
        end

        # Organizes dependencies between typical reactions
        def organize_typical_reactions(res)
          reactions_lists = [res.typical_reactions, res.lateral_reactions]
          organize_typical_reactions_deps!(*reactions_lists)
        end

        # Organizes dependencies between lateral reactions
        def organize_lateral_reactions(res)
          organize_lateral_reactions_deps!(res.lateral_reactions)
        end
      end
    end
  end
end
