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
          :vinyl_on_bridge_base,
          :methyl_on_dimer_base,
          :vinyl_on_dimer_base,
          :two_methyls_on_dimer_base,
          :methyl_on_extended_bridge_base,
          :methyl_on_right_bridge_base,
          :cross_bridge_on_bridges_base,
          :cross_bridge_on_dimers_base,
          :three_bridges_base,
          :bridge_with_dimer_base
        ])

        define_dependents(DependentSpecificSpec, [
          :activated_bridge,
          :activated_dimer,
          :activated_incoherent_bridge,
          :activated_incoherent_dimer,
          :activated_methyl_on_bridge,
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
          :methyl,
          :methyl_on_activated_bridge,
          :methyl_on_bridge,
          :methyl_on_incoherent_bridge,
          :right_bottom_hydrogenated_activated_dimer,
          :right_hydrogenated_bridge,
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
          :methyl_desorption,
          :methyl_incorporation,
          :dimer_formation,
          :sierpinski_drop,
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