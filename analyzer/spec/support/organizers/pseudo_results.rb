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
        def stub_results(depts)
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

        # Provides default value for analysis result methods
        # @return [Hash] the hash where each value is empty array
        def default_depts
          Hash[default_keys.map { |c| [c, []] }]
        end

        # Sorts in order of default depts keys
        # @return [Array] the array of sorted pairs
        def sort_depts(depts)
          depts.sort_by { |k, _| default_keys.index(k) }
        end

        # Extends passed depts hash by adding all internal species
        # @return [Hash] the fixed cache of depts
        def fix(depts)
          ordered_depts = sort_depts(default_depts.merge(depts))
          all_names = ordered_depts.flat_map(&:last).map(&:name).to_set
          depts_cache = Hash[ordered_depts]

          fix_reactants(depts_cache, all_names)
          fix_sidepieces(depts_cache, all_names)
          fix_bases(depts_cache, all_names)

          depts_cache
        end

        # Extends passed variables by reactant specs
        def fix_reactants(depts_cache, all_names)
          [:ubiquitous_reactions, :typical_reactions, :lateral_reactions].each do |k|
            depts_cache[k].each do |dr|
              r = dr.reaction
              r.source.each do |s|
                next if all_names.include?(s.name)
                if s.is_a?(Concepts::TerminationSpec)
                  all_names << s.name
                  depts_cache[:term_specs] << DependentTermination.new(s)
                else
                  store_reactant(dr, depts_cache, all_names, s)
                end
              end
            end
          end
        end

        # Extends passed variables by sidepieces from where objects
        def fix_sidepieces(depts_cache, all_names)
          depts_cache[:lateral_reactions].flat_map(&:theres).each do |th|
            th.where.specs.each do |s|
              next if all_names.include?(s.name)
              store_reactant(th, depts_cache, all_names, s)
            end
          end
        end

        # Extends passed variables by base specs from specific specs
        def fix_bases(depts_cache, all_names)
          depts_cache[:specific_specs].each do |ds|
            next if all_names.include?(ds.spec.spec.name)
            all_names << ds.spec.spec.name
            depts_cache[:base_specs] << DependentBaseSpec.new(ds.spec.spec)
          end
        end

        # Provides lambda which checks type of own argument and wraps and store it
        # to passed variables
        def store_reactant(dcont, depts_cache, all_names, spec)
          if spec.is_a?(Concepts::SpecificSpec)
            ds = DependentSpecificSpec.new(spec)
            if ds.specific?
              all_names << spec.name
              depts_cache[:specific_specs] << ds
              store_concept_to(dcont, ds)
            else
              dbs = depts_cache[:base_specs].find { |bs| bs.name == spec.spec.name }
              dbs ||= DependentBaseSpec.new(spec.spec)
              dcont.swap_source(spec, dbs.spec)
              unless all_names.include?(dbs.name)
                all_names << dbs.name
                depts_cache[:base_specs] << dbs
              end
              store_concept_to(dcont, dbs)
            end
          elsif spec.is_a?(Concepts::Spec)
            dbs = DependentBaseSpec.new(spec)
            all_names << spec.name
            depts_cache[:base_specs] << dbs
            store_concept_to(dcont, dbs)
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
