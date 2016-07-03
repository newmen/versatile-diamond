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

        # Anytime returns a new instance of fake reaction
        def fake_reaction
          FakeReaction.new
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
          :trimer_base,
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
          :dimer_near_mob_base,
          :two_methyls_on_dimer_base,
          :vinyl_on_bridge_base,
          :vinyl_on_dimer_base
        ])

        define_dependents(DependentSpecificSpec, [
          :activated_bridge,
          :activated_hydrogenated_bridge,
          :activated_dimer,
          :activated_incoherent_bridge,
          :activated_incoherent_dimer,
          :activated_methyl_on_bridge,
          :extra_activated_methyl_on_bridge,
          :hydrogenated_methyl_on_bridge,
          :incoherent_hydrogenated_methyl_on_bridge,
          :twise_activated_cross_bridge_on_bridges,
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
          :incoherent_hydrogenated_high_bridge,
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
          :ea_dimer_near_ea_mob,
          :top_activated_methyl_on_activated_half_extended_bridge,
          :lower_activated_methyl_on_activated_half_extended_bridge,
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
          :vinyl_adsorption,
          :methyl_desorption,
          :vinyl_desorption,
          :methyl_incorporation,
          :methyl_to_gap,
          :two_next_dimers_formation,
          :two_side_dimers_formation,
          :intermed_migr_db_formation,
          :intermed_migr_dc_formation,
          :intermed_migr_dh_formation,
          :intermed_migr_df_formation,
          :intermed_migr_dmod_formation,
          :dimer_formation,
          :bhad_activation,
          :symmetric_dimer_formation,
          :incoherent_dimer_drop,
          :sierpinski_drop,
          :cbod_drop,
          :migration_over_111,
          :hydrogen_abs_from_gap,
          :hydrogen_migration,
          :high_bridge_to_methyl_on_dimer,
          :high_bridge_stand_to_dimer,
          :ih_high_bridge_stand_to_dimer,
          :one_dimer_hydrogen_migration
        ])
        set(:dept_dimer_drop) do
          Organizers::DependentTypicalReaction.new(dimer_formation.reverse)
        end
        set(:dept_sierpinski_formation) do
          Organizers::DependentTypicalReaction.new(sierpinski_drop.reverse)
        end
        set(:dept_intermed_migr_db_drop) do
          Organizers::DependentTypicalReaction.new(intermed_migr_db_formation.reverse)
        end
        set(:dept_intermed_migr_dc_drop) do
          Organizers::DependentTypicalReaction.new(intermed_migr_dc_formation.reverse)
        end
        set(:dept_intermed_migr_dh_drop) do
          Organizers::DependentTypicalReaction.new(intermed_migr_dh_formation.reverse)
        end
        set(:dept_intermed_migr_df_drop) do
          Organizers::DependentTypicalReaction.new(intermed_migr_df_formation.reverse)
        end
        set(:dept_reverse_migration_over_111) do
          Organizers::DependentTypicalReaction.new(migration_over_111.reverse)
        end

        define_dependents(DependentLateralReaction, [
          :end_lateral_idd,
          :end_lateral_df,
          :middle_lateral_df,
          :ewb_lateral_df,
          :mwb_lateral_df,
          :de_lateral_mi,
          :small_ab_lateral_sdf,
          :big_ab_lateral_sdf
        ])

        define_dependent_theres([
          [:on_end, :end_lateral_df],
          [:on_middle, :middle_lateral_df]
        ])

        set(:end_chunk) { dept_end_lateral_df.chunk }
        set(:middle_chunk) { dept_middle_lateral_df.chunk }
        set(:ewb_chunk) { dept_ewb_lateral_df.chunk }
        set(:mwb_chunk) { dept_mwb_lateral_df.chunk }
      end

    end
  end
end
