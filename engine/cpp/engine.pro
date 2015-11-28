TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CXXFLAGS_RELEASE += -DNDEBUG
#QMAKE_CXXFLAGS += -D_GLIBCXX_DEBUG_PEDANTIC
#QMAKE_CXXFLAGS += -DPRINT

QMAKE_CXXFLAGS += -std=c++11 -I../hand-generations/src
LIBS += -lyaml-cpp

SOURCES += \
    ../hand-generations/src/atoms/c.cpp \
    ../hand-generations/src/env.cpp \
    ../hand-generations/src/finder.cpp \
    ../hand-generations/src/handbook.cpp \
    ../hand-generations/src/phases/diamond.cpp \
    ../hand-generations/src/phases/phase_boundary.cpp \
    ../hand-generations/src/reactions/central/dimer_drop.cpp \
    ../hand-generations/src/reactions/central/dimer_formation.cpp \
    ../hand-generations/src/reactions/lateral/dimer_drop_at_end.cpp \
    ../hand-generations/src/reactions/lateral/dimer_drop_in_middle.cpp \
    ../hand-generations/src/reactions/lateral/dimer_formation_at_end.cpp \
    ../hand-generations/src/reactions/lateral/dimer_formation_in_middle.cpp \
    ../hand-generations/src/reactions/rates_reader.cpp \
    ../hand-generations/src/reactions/typical/abs_hydrogen_from_gap.cpp \
    ../hand-generations/src/reactions/typical/ads_methyl_to_111.cpp \
    ../hand-generations/src/reactions/typical/ads_methyl_to_dimer.cpp \
    ../hand-generations/src/reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.cpp \
    ../hand-generations/src/reactions/typical/des_methyl_from_111.cpp \
    ../hand-generations/src/reactions/typical/des_methyl_from_bridge.cpp \
    ../hand-generations/src/reactions/typical/des_methyl_from_dimer.cpp \
    ../hand-generations/src/reactions/typical/dimer_drop_near_bridge.cpp \
    ../hand-generations/src/reactions/typical/dimer_formation_near_bridge.cpp \
    ../hand-generations/src/reactions/typical/form_two_bond.cpp \
    ../hand-generations/src/reactions/typical/high_bridge_stand_to_dimer.cpp \
    ../hand-generations/src/reactions/typical/high_bridge_stand_to_one_bridge.cpp \
    ../hand-generations/src/reactions/typical/high_bridge_to_methyl.cpp \
    ../hand-generations/src/reactions/typical/high_bridge_to_two_bridges.cpp \
    ../hand-generations/src/reactions/typical/methyl_on_dimer_hydrogen_migration.cpp \
    ../hand-generations/src/reactions/typical/methyl_to_high_bridge.cpp \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer.cpp \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer_from_111.cpp \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer_from_dimer.cpp \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer_from_high_bridge.cpp \
    ../hand-generations/src/reactions/typical/migration_down_in_gap.cpp \
    ../hand-generations/src/reactions/typical/migration_down_in_gap_from_111.cpp \
    ../hand-generations/src/reactions/typical/migration_down_in_gap_from_dimer.cpp \
    ../hand-generations/src/reactions/typical/migration_down_in_gap_from_high_bridge.cpp \
    ../hand-generations/src/reactions/typical/migration_through_dimers_row.cpp \
    ../hand-generations/src/reactions/typical/next_level_bridge_to_high_bridge.cpp \
    ../hand-generations/src/reactions/typical/sierpinski_drop.cpp \
    ../hand-generations/src/reactions/typical/two_bridges_to_high_bridge.cpp \
    ../hand-generations/src/reactions/ubiquitous/local/methyl_on_dimer_activation.cpp \
    ../hand-generations/src/reactions/ubiquitous/local/methyl_on_dimer_deactivation.cpp \
    ../hand-generations/src/reactions/ubiquitous/surface_activation.cpp \
    ../hand-generations/src/reactions/ubiquitous/surface_deactivation.cpp \
    ../hand-generations/src/run.cpp \
    ../hand-generations/src/species/base/bridge.cpp \
    ../hand-generations/src/species/base/bridge_cri.cpp \
    ../hand-generations/src/species/base/bridge_with_dimer.cpp \
    ../hand-generations/src/species/base/methyl_on_bridge.cpp \
    ../hand-generations/src/species/base/methyl_on_dimer.cpp \
    ../hand-generations/src/species/base/original_bridge.cpp \
    ../hand-generations/src/species/base/two_bridges.cpp \
    ../hand-generations/src/species/empty/symmetric_bridge.cpp \
    ../hand-generations/src/species/empty/symmetric_cross_bridge_on_bridges.cpp \
    ../hand-generations/src/species/empty/symmetric_dimer.cpp \
    ../hand-generations/src/species/empty/symmetric_dimer_cri_cli.cpp \
    ../hand-generations/src/species/sidepiece/dimer.cpp \
    ../hand-generations/src/species/sidepiece/original_dimer.cpp \
    ../hand-generations/src/species/specific/bridge_crh.cpp \
    ../hand-generations/src/species/specific/bridge_crs.cpp \
    ../hand-generations/src/species/specific/bridge_crs_cti_cli.cpp \
    ../hand-generations/src/species/specific/bridge_ctsi.cpp \
    ../hand-generations/src/species/specific/bridge_with_dimer_cbti_cbrs_cdli.cpp \
    ../hand-generations/src/species/specific/bridge_with_dimer_cdli.cpp \
    ../hand-generations/src/species/specific/cross_bridge_on_bridges.cpp \
    ../hand-generations/src/species/specific/dimer_cri_cli.cpp \
    ../hand-generations/src/species/specific/dimer_crs.cpp \
    ../hand-generations/src/species/specific/dimer_crs_cli.cpp \
    ../hand-generations/src/species/specific/high_bridge.cpp \
    ../hand-generations/src/species/specific/high_bridge_cms.cpp \
    ../hand-generations/src/species/specific/methyl_on_111_cmiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_111_cmsiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_111_cmssiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbi_cmiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbi_cmsiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbi_cmssiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbs_cmsiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_dimer_cls_cmhiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_dimer_cmiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_dimer_cmsiu.cpp \
    ../hand-generations/src/species/specific/methyl_on_dimer_cmssiu.cpp \
    ../hand-generations/src/species/specific/original_cross_bridge_on_bridges.cpp \
    ../hand-generations/src/species/specific/original_dimer_cri_cli.cpp \
    ../hand-generations/src/species/specific/two_bridges_ctri_cbrs.cpp \
    atoms/atom.cpp \
    mc/base_events_container.cpp \
    mc/common_mc_data.cpp \
    mc/counter.cpp \
    mc/events_container.cpp \
    mc/multi_events_container.cpp \
    mc/random_generator.cpp \
    phases/amorph.cpp \
    phases/behavior_factory.cpp \
    phases/behavior_plane.cpp \
    phases/behavior_tor.cpp \
    phases/crystal.cpp \
    reactions/central_reaction.cpp \
    reactions/lateral_reaction.cpp \
    reactions/typical_reaction.cpp \
    reactions/ubiquitous_reaction.cpp \
    species/base_spec.cpp \
    species/lateral_spec.cpp \
    species/parent_spec.cpp \
    species/specific_spec.cpp \
    tools/debug_print.cpp \
    tools/indent_stream.cpp \
    tools/process_mem_usage.cpp \
    tools/savers/accumulator.cpp \
    tools/savers/all_atoms_detector.cpp \
    tools/savers/bond_info.cpp \
    tools/savers/crystal_slice_saver.cpp \
    tools/savers/mol_accumulator.cpp \
    tools/savers/mol_format.cpp \
    tools/savers/mol_saver.cpp \
    tools/savers/sdf_saver.cpp \
    tools/savers/volume_saver_factory.cpp \
    tools/savers/xyz_accumulator.cpp \
    tools/savers/xyz_format.cpp \
    tools/savers/xyz_saver.cpp \
    tools/scavenger.cpp \
    ../hand-generations/src/main.cpp \
#    ../tests/units/c_spec.cpp \
#    ../tests/units/diamond_relations_spec.cpp \
#    ../tests/units/diamond_spec.cpp \
#    ../tests/units/find_spec.cpp \
#    ../tests/units/lattice_spec. \cpp \
#    ../tests/units/vector3d_spec \.cpp \
#    ../tests/support/open_diamond.cpp \
    tools/yaml_config_reader.cpp

HEADERS += \
    ../hand-generations/src/atoms/atom_builder.h \
    ../hand-generations/src/atoms/c.h \
    ../hand-generations/src/atoms/specified_atom.h \
    ../hand-generations/src/env.h \
    ../hand-generations/src/finder.h \
    ../hand-generations/src/handbook.h \
    ../hand-generations/src/names.h \
    ../hand-generations/src/phases/diamond.h \
    ../hand-generations/src/phases/diamond_atoms_iterator.h \
    ../hand-generations/src/phases/diamond_crystal_properties.h \
    ../hand-generations/src/phases/diamond_relations.h \
    ../hand-generations/src/phases/phase_boundary.h \
    ../hand-generations/src/reactions/central.h \
    ../hand-generations/src/reactions/central/dimer_drop.h \
    ../hand-generations/src/reactions/central/dimer_formation.h \
    ../hand-generations/src/reactions/concretizable_role.h \
    ../hand-generations/src/reactions/lateral.h \
    ../hand-generations/src/reactions/lateral/dimer_drop_at_end.h \
    ../hand-generations/src/reactions/lateral/dimer_drop_in_middle.h \
    ../hand-generations/src/reactions/lateral/dimer_formation_at_end.h \
    ../hand-generations/src/reactions/lateral/dimer_formation_in_middle.h \
    ../hand-generations/src/reactions/local.h \
    ../hand-generations/src/reactions/multi_lateral.h \
    ../hand-generations/src/reactions/rates_reader.h \
    ../hand-generations/src/reactions/registrator.h \
    ../hand-generations/src/reactions/single_lateral.h \
    ../hand-generations/src/reactions/typical.h \
    ../hand-generations/src/reactions/typical/abs_hydrogen_from_gap.h \
    ../hand-generations/src/reactions/typical/ads_methyl_to_111.h \
    ../hand-generations/src/reactions/typical/ads_methyl_to_dimer.h \
    ../hand-generations/src/reactions/typical/bridge_with_dimer_to_high_bridge_and_dimer.h \
    ../hand-generations/src/reactions/typical/des_methyl_from_111.h \
    ../hand-generations/src/reactions/typical/des_methyl_from_bridge.h \
    ../hand-generations/src/reactions/typical/des_methyl_from_dimer.h \
    ../hand-generations/src/reactions/typical/dimer_drop_near_bridge.h \
    ../hand-generations/src/reactions/typical/dimer_formation_near_bridge.h \
    ../hand-generations/src/reactions/typical/form_two_bond.h \
    ../hand-generations/src/reactions/typical/high_bridge_stand_to_dimer.h \
    ../hand-generations/src/reactions/typical/high_bridge_stand_to_one_bridge.h \
    ../hand-generations/src/reactions/typical/high_bridge_to_methyl.h \
    ../hand-generations/src/reactions/typical/high_bridge_to_two_bridges.h \
    ../hand-generations/src/reactions/typical/lookers/near_activated_dimer.h \
    ../hand-generations/src/reactions/typical/lookers/near_gap.h \
    ../hand-generations/src/reactions/typical/lookers/near_high_bridge.h \
    ../hand-generations/src/reactions/typical/lookers/near_methyl_on_111.h \
    ../hand-generations/src/reactions/typical/lookers/near_methyl_on_bridge.h \
    ../hand-generations/src/reactions/typical/lookers/near_methyl_on_bridge_cbi.h \
    ../hand-generations/src/reactions/typical/lookers/near_methyl_on_dimer.h \
    ../hand-generations/src/reactions/typical/lookers/near_part_of_gap.h \
    ../hand-generations/src/reactions/typical/methyl_on_dimer_hydrogen_migration.h \
    ../hand-generations/src/reactions/typical/methyl_to_high_bridge.h \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer.h \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer_from_111.h \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer_from_dimer.h \
    ../hand-generations/src/reactions/typical/migration_down_at_dimer_from_high_bridge.h \
    ../hand-generations/src/reactions/typical/migration_down_in_gap.h \
    ../hand-generations/src/reactions/typical/migration_down_in_gap_from_111.h \
    ../hand-generations/src/reactions/typical/migration_down_in_gap_from_dimer.h \
    ../hand-generations/src/reactions/typical/migration_down_in_gap_from_high_bridge.h \
    ../hand-generations/src/reactions/typical/migration_through_dimers_row.h \
    ../hand-generations/src/reactions/typical/next_level_bridge_to_high_bridge.h \
    ../hand-generations/src/reactions/typical/sierpinski_drop.h \
    ../hand-generations/src/reactions/typical/two_bridges_to_high_bridge.h \
    ../hand-generations/src/reactions/ubiquitous.h \
    ../hand-generations/src/reactions/ubiquitous/data/activation_data.h \
    ../hand-generations/src/reactions/ubiquitous/data/deactivation_data.h \
    ../hand-generations/src/reactions/ubiquitous/local/methyl_on_dimer_activation.h \
    ../hand-generations/src/reactions/ubiquitous/local/methyl_on_dimer_deactivation.h \
    ../hand-generations/src/reactions/ubiquitous/surface_activation.h \
    ../hand-generations/src/reactions/ubiquitous/surface_deactivation.h \
    ../hand-generations/src/run.h \
    ../hand-generations/src/species/base.h \
    ../hand-generations/src/species/base/bridge.h \
    ../hand-generations/src/species/base/bridge_cri.h \
    ../hand-generations/src/species/base/bridge_with_dimer.h \
    ../hand-generations/src/species/base/methyl_on_bridge.h \
    ../hand-generations/src/species/base/methyl_on_dimer.h \
    ../hand-generations/src/species/base/original_bridge.h \
    ../hand-generations/src/species/base/two_bridges.h \
    ../hand-generations/src/species/empty/symmetric_bridge.h \
    ../hand-generations/src/species/empty/symmetric_cross_bridge_on_bridges.h \
    ../hand-generations/src/species/empty/symmetric_dimer.h \
    ../hand-generations/src/species/empty/symmetric_dimer_cri_cli.h \
    ../hand-generations/src/species/empty_base.h \
    ../hand-generations/src/species/empty_specific.h \
    ../hand-generations/src/species/overall.h \
    ../hand-generations/src/species/sidepiece.h \
    ../hand-generations/src/species/sidepiece/dimer.h \
    ../hand-generations/src/species/sidepiece/original_dimer.h \
    ../hand-generations/src/species/specific.h \
    ../hand-generations/src/species/specific/bridge_crh.h \
    ../hand-generations/src/species/specific/bridge_crs.h \
    ../hand-generations/src/species/specific/bridge_crs_cti_cli.h \
    ../hand-generations/src/species/specific/bridge_ctsi.h \
    ../hand-generations/src/species/specific/bridge_with_dimer_cbti_cbrs_cdli.h \
    ../hand-generations/src/species/specific/bridge_with_dimer_cdli.h \
    ../hand-generations/src/species/specific/cross_bridge_on_bridges.h \
    ../hand-generations/src/species/specific/dimer_cri_cli.h \
    ../hand-generations/src/species/specific/dimer_crs.h \
    ../hand-generations/src/species/specific/dimer_crs_cli.h \
    ../hand-generations/src/species/specific/high_bridge.h \
    ../hand-generations/src/species/specific/high_bridge_cms.h \
    ../hand-generations/src/species/specific/methyl_on_111_cmiu.h \
    ../hand-generations/src/species/specific/methyl_on_111_cmsiu.h \
    ../hand-generations/src/species/specific/methyl_on_111_cmssiu.h \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbi_cmiu.h \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbi_cmsiu.h \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbi_cmssiu.h \
    ../hand-generations/src/species/specific/methyl_on_bridge_cbs_cmsiu.h \
    ../hand-generations/src/species/specific/methyl_on_dimer_cls_cmhiu.h \
    ../hand-generations/src/species/specific/methyl_on_dimer_cmiu.h \
    ../hand-generations/src/species/specific/methyl_on_dimer_cmsiu.h \
    ../hand-generations/src/species/specific/methyl_on_dimer_cmssiu.h \
    ../hand-generations/src/species/specific/original_cross_bridge_on_bridges.h \
    ../hand-generations/src/species/specific/original_dimer_cri_cli.h \
    ../hand-generations/src/species/specific/two_bridges_ctri_cbrs.h \
    atoms/atom.h \
    atoms/contained_species.h \
    atoms/lattice.h \
    atoms/neighbours.h \
    mc/base_events_container.h \
    mc/common_mc_data.h \
    mc/counter.h \
    mc/events_container.h \
    mc/mc.h \
    mc/multi_events_container.h \
    mc/random_generator.h \
    phases/amorph.h \
    phases/atoms_vector3d.h \
    phases/behavior.h \
    phases/behavior_factory.h \
    phases/behavior_plane.h \
    phases/behavior_tor.h \
    phases/crystal.h \
    phases/crystal_atoms_iterator.h \
    reactions/central_reaction.h \
    reactions/concrete_lateral_reaction.h \
    reactions/concrete_typical_reaction.h \
    reactions/lateral_factories/chain_factory.h \
    reactions/lateral_factories/duo_lateral_factory.h \
    reactions/lateral_factories/lateral_creation_lambda.h \
    reactions/lateral_factories/lateral_factory.h \
    reactions/lateral_factories/uno_lateral_factory.h \
    reactions/lateral_reaction.h \
    reactions/multi_lateral_reaction.h \
    reactions/reaction.h \
    reactions/single_lateral_reaction.h \
    reactions/spec_reaction.h \
    reactions/targets.h \
    reactions/typical_reaction.h \
    reactions/ubiquitous_reaction.h \
    species/additional_atoms_wrapper.h \
    species/atoms_swap_wrapper.h \
    species/base_spec.h \
    species/child_spec.h \
    species/dependent_spec.h \
    species/keeper.h \
    species/lateral_spec.h \
    species/localable_role.h \
    species/parent_spec.h \
    species/parents_swap_proxy.h \
    species/parents_swap_wrapper.h \
    species/reactant.h \
    species/sealer.h \
    species/source_spec.h \
    species/specific_spec.h \
    species/symmetric.h \
    tools/collector.h \
    tools/common.h \
    tools/creator.h \
    tools/debug_print.h \
    tools/error.h \
    tools/factory.h \
    tools/indent_facet.h \
    tools/indent_stream.h \
    tools/init_config.h \
    tools/many_items_result.h \
    tools/process_mem_usage.h \
    tools/runner.h \
    tools/savers/accumulator.h \
    tools/savers/actives_portion_counter.h \
    tools/savers/all_atoms_detector.h \
    tools/savers/atom_info.h \
    tools/savers/bond_info.h \
    tools/savers/bundle_saver.h \
    tools/savers/crystal_slice_saver.h \
    tools/savers/detector.h \
    tools/savers/detector_factory.h \
    tools/savers/format.h \
    tools/savers/many_files.h \
    tools/savers/mol_accumulator.h \
    tools/savers/mol_format.h \
    tools/savers/mol_saver.h \
    tools/savers/one_file.h \
    tools/savers/sdf_saver.h \
    tools/savers/surface_detector.h \
    tools/savers/volume_saver.h \
    tools/savers/volume_saver_factory.h \
    tools/savers/xyz_accumulator.h \
    tools/savers/xyz_format.h \
    tools/savers/xyz_saver.h \
    tools/scavenger.h \
    tools/short_types.h \
    tools/typed.h \
    tools/vector3d.h \
#    ../tests/support/open_diamond.h \
    tools/yaml_config_reader.h

OTHER_FILES += \
    ../hand-generations/src/configs/env.yml \
    ../hand-generations/src/configs/reactions.yml \
    ../hand-generations/atoms_transitive_graph.png
