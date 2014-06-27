module VersatileDiamond
  module Organizers
    module Support

      # Provides concept instances for RSpec
      module Handbook
        include Tools::Handbook
        include SpeciesOrganizer

        # Defines dependent species
        def self.define_dependents(klass, concept_names)
          concept_names.each do |name|
            set(:"dept_#{name}") { klass.new(send(name)) }
          end
        end

        # Organize dependenceis between passed specific species and base species
        # of them
        #
        # @param [Array] specific_species the array of organizing species
        def organize(specific_species)
          original_bases = specific_species.map(&:base_spec)
          wrapped_bases = original_bases.map { |s| DependentBaseSpec.new(s) }
          base_cache = make_cache(wrapped_bases)
          organize_spec_dependencies!(base_cache, specific_species)
        end

        define_dependents(DependentTermination, [
          :active_bond,
          :adsorbed_h,
          :adsorbed_cl
        ])

        define_dependents(DependentSimpleSpec, [
          :hydrogen_ion
        ])

        define_dependents(DependentBaseSpec, [
          :bridge_base,
          :bridge_base_dup,
          :dimer_base,
          :extended_bridge_base,
          :extended_dimer_base,
          :high_bridge_base,
          :methane_base,
          :methyl_on_bridge_base,
          :methyl_on_bridge_base_dup,
          :methyl_on_dimer_base,
          :methyl_on_extended_bridge_base,
          :methyl_on_right_bridge_base,
          :cross_bridge_on_bridges_base,
          :three_bridges_base
        ])

        define_dependents(DependentSpecificSpec, [
          :activated_bridge,
          :activated_dimer,
          :activated_incoherent_bridge,
          :activated_methyl_on_bridge,
          :activated_methyl_on_dimer,
          :activated_methyl_on_incoherent_bridge,
          :activated_methyl_on_right_bridge,
          :bridge,
          :chlorigenated_bridge,
          :dimer,
          :extra_activated_bridge,
          :extra_hydrogenated_bridge,
          :high_bridge,
          :hydrogenated_bridge,
          :hydrogenated_incoherent_bridge,
          :methyl,
          :methyl_on_bridge,
          :methyl_on_activated_bridge,
          :methyl_on_incoherent_bridge,
          :right_hydrogenated_bridge,
          :unfixed_methyl_on_bridge,
          :unfixed_activated_methyl_on_incoherent_bridge
        ])

        define_dependents(DependentUbiquitousReaction, [
          :surface_activation,
          :surface_deactivation
        ])

        define_dependents(DependentTypicalReaction, [
          :methyl_activation,
          :methyl_deactivation,
          :methyl_desorption,
          :dimer_formation,
          :hydrogen_migration
        ])

        define_dependents(DependentLateralReaction, [
          :end_lateral_df,
          :middle_lateral_df
        ])

        define_dependents(DependentThere, [
          :on_end
        ])
      end

    end
  end
end