module VersatileDiamond
  module Organizers
    module Support

      # Provides concept instances for RSpec
      module Handbook
        include Tools::Handbook
        include SpeciesOrganizer

        class << self
          # Defines dependent instances
          def define_dependents(klass, concept_names)
            concept_names.each do |name|
              set(:"dept_#{name}") { klass.new(send(name)) }
            end
          end

          # Defines dependent theres
          def define_dependent_theres(zipped_names_with_reactions)
            zipped_names_with_reactions.each do |there_name, reaction_name|
              set(:"dept_#{there_name}") do
                DependentThere.new(send("dept_#{reaction_name}"), send(there_name))
              end
            end
          end
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
          :bridge_with_dimer_base,
          :cross_bridge_on_bridges_base,
          :cross_bridge_on_dimers_base,
          :dimer_base,
          :dimer_base_dup,
          :extended_bridge_base,
          :extended_dimer_base,
          :high_bridge_base,
          :intermed_migr_down_full_base,
          :intermed_migr_down_half_base,
          :intermed_migr_down_common_base,
          :intermed_migr_down_bridge_base,
          :methane_base,
          :methyl_on_bridge_base,
          :methyl_on_bridge_base_dup,
          :methyl_on_dimer_base,
          :methyl_on_extended_bridge_base,
          :top_methyl_on_half_extended_bridge_base,
          :lower_methyl_on_half_extended_bridge_base,
          :methyl_on_right_bridge_base,
          :three_bridges_base,
          :two_methyls_on_dimer_base,
          :vinyl_on_bridge_base,
          :vinyl_on_dimer_base
        ])

        define_dependents(DependentSpecificSpec, [
          :activated_bridge,
          :activated_dimer,
          :activated_incoherent_bridge,
          :activated_incoherent_dimer,
          :activated_methyl_on_bridge,
          :extra_activated_methyl_on_bridge,
          :activated_methyl_on_dimer,
          :activated_methyl_on_incoherent_bridge,
          :activated_methyl_on_right_bridge,
          :bottom_hydrogenated_activated_dimer,
          :bridge,
          :chlorigenated_bridge,
          :dimer,
          :extra_activated_bridge,
          :extra_hydrogenated_bridge,
          :high_bridge,
          :hydrogenated_bridge,
          :hydrogenated_incoherent_bridge,
          :incoherent_methyl_on_bridge,
          :methyl,
          :methyl_on_activated_bridge,
          :methyl_on_bridge,
          :methyl_on_incoherent_bridge,
          :right_bottom_hydrogenated_activated_dimer,
          :right_hydrogenated_bridge,
          :right_activated_bridge,
          :twise_incoherent_dimer,
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
          :methyl_adsorption,
          :methyl_desorption,
          :methyl_incorporation,
          :methyl_to_gap,
          :two_dimers_form,
          :intermed_migr_dc_formation,
          :intermed_migr_dh_formation,
          :intermed_migr_df_formation,
          :intermed_migr_dmod_formation,
          :dimer_formation,
          :incoherent_dimer_drop,
          :sierpinski_drop,
          :hydrogen_abs_from_gap,
          :hydrogen_migration
        ])
        set(:dept_sierpinski_formation) do
          Organizers::DependentTypicalReaction.new(sierpinski_drop.reverse)
        end

        define_dependents(DependentLateralReaction, [
          :end_lateral_df,
          :middle_lateral_df
        ])

        define_dependent_theres([
          [:on_end, :end_lateral_df],
          [:on_middle, :middle_lateral_df]
        ])
      end

    end
  end
end