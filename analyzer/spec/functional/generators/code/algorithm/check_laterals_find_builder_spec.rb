require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe CheckLateralsFindBuilder, type: :algorithm, use: :chunks do
          let(:generator) do
            stub_generator(
              base_specs: respond_to?(:base_specs) ? base_specs : [],
              specific_specs: respond_to?(:specific_specs) ? specific_specs : [],
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end

          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:specie) { generator.specie_class(spec.name) }
          let(:classifier) { generator.classifier }
          let(:builder) { reaction.check_laterals_builder_from(specie) }
          let(:lateral_chunks) { reaction.lateral_chunks }

          let(:target_specs) { lateral_chunks.target_specs.to_a }
          let(:sidepiece_specs) { lateral_chunks.sidepiece_specs.to_a }

          let(:generating_class_names) { combined_lateral_reactions.map(&:class_name) }
          let(:combined_lateral_reactions) do
            lateral_chunks.unconcrete_affixes - lateral_reactions.map do |lr|
              generator.reaction_class(lr.name)
            end
          end

          describe '#build' do
            describe 'dimers row formation near asymmetric dimer' do
              let(:typical_reaction) { dept_dimer_formation }
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }

              let(:lateral_dimer) { sidepiece_spec_by_name(:dimer) }

              let(:ab_ct) { role(dept_activated_bridge, :ct) }
              let(:aib_ct) { role(dept_activated_incoherent_bridge, :ct) }

              describe 'just cross neighbours' do
                let(:spec) { lateral_dimer }
                let(:find_algorithm) do
                  <<-CODE
    sidepiece->eachSymmetry([](LateralSpec *symmetricDimer1) {
        Atom *atoms1[2] = { symmetricDimer1->atom(3), symmetricDimer1->atom(0) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricDimer1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{ab_ct}) && neighbours1[1]->is(#{aib_ct}))
            {
                BridgeCTsi *bridgeCTsi1 = neighbours1[1]->specByRole<BridgeCTsi>(#{aib_ct});
                if (bridgeCTsi1)
                {
                    BridgeCTs *bridgeCTs1 = neighbours1[0]->specByRole<BridgeCTs>(#{ab_ct});
                    if (bridgeCTs1)
                    {
                        SpecificSpec *targets[2] = { bridgeCTs1, bridgeCTsi1 };
                        ChainFactory<
                            DuoLateralFactory,
                            #{class_name},
                            ForwardDimerFormation
                        > factory(symmetricDimer1, targets);
                        factory.checkoutReactions<#{class_name}>();
                    }
                }
            }
        });
    });
                  CODE
                end

                it_behaves_like :check_code do
                  let(:lateral_reactions) { [dept_end_lateral_df] }
                  let(:class_name) { 'ForwardDimerFormationEndLateral' }
                end

                it_behaves_like :check_code do
                  let(:lateral_reactions) { [dept_middle_lateral_df] }
                  let(:class_name) { generating_class_names.first }
                end
              end

              describe 'three sides neighbours' do
                let(:lateral_reactions) { [dept_ewb_lateral_df] }
                let(:class_name_with_bridge) { generating_class_names[0] }
                let(:class_name_with_dimer) { generating_class_names[1] }
                let(:class_name_with_two_dimer) { generating_class_names[2] }

                it_behaves_like :check_code do
                  let(:spec) { lateral_dimer }
                  let(:find_algorithm) do
                    <<-CODE
    sidepiece->eachSymmetry([](LateralSpec *symmetricDimer1) {
        Atom *atoms1[2] = { symmetricDimer1->atom(3), symmetricDimer1->atom(0) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricDimer1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{ab_ct}) && neighbours1[1]->is(#{aib_ct}))
            {
                BridgeCTsi *bridgeCTsi1 = neighbours1[1]->specByRole<BridgeCTsi>(#{aib_ct});
                if (bridgeCTsi1)
                {
                    BridgeCTs *bridgeCTs1 = neighbours1[0]->specByRole<BridgeCTs>(#{ab_ct});
                    if (bridgeCTs1)
                    {
                        SpecificSpec *targets[2] = { bridgeCTs1, bridgeCTsi1 };
                        ChainFactory<
                            DuoLateralFactory,
                            #{class_name_with_dimer},
                            ForwardDimerFormation
                        > factory(symmetricDimer1, targets);
                        factory.checkoutReactions<
                            #{class_name_with_bridge},
                            #{class_name_with_dimer},
                            ForwardDimerFormationEwbLateral
                        >();
                    }
                }
            }
        });
    });
                    CODE
                  end
                end

                it_behaves_like :check_code do
                  let(:lateral_bridge) { (sidepiece_specs - [lateral_dimer]).first }
                  let(:spec) { lateral_bridge }
                  let(:find_algorithm) do
                    <<-CODE
    Atom *atom1 = sidepiece->atom(0);
    eachNeighbour(atom1, &Diamond::front_100, [&sidepiece](Atom *neighbour1) {
        if (neighbour1->is(#{aib_ct}))
        {
            BridgeCTsi *bridgeCTsi1 = neighbour1->specByRole<BridgeCTsi>(#{aib_ct});
            if (bridgeCTsi1)
            {
                ChainFactory<
                    UnoLateralFactory,
                    #{class_name_with_bridge},
                    ForwardDimerFormation
                > factory(sidepiece, bridgeCTsi1);
                factory.checkoutReactions<
                    #{class_name_with_dimer},
                    #{class_name_with_two_dimer}
                >();
            }
        }
    });
                    CODE
                  end
                end
              end
            end

            describe 'dimer formation near bridge' do
              it_behaves_like :check_code do
                let(:typical_reaction) { dept_dimer_formation_near_bridge }
                let(:lateral_reactions) do
                  [dept_end_lateral_dfnb, dept_middle_lateral_dfnb]
                end
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }

                let(:lateral_dimer) { sidepiece_spec_by_name(:dimer) }
                let(:spec) { lateral_dimer }

                let(:ab_ct) { role(dept_activated_bridge, :ct) }
                let(:ab_cr) { role(dept_right_activated_bridge, :cr) }

                let(:find_algorithm) do
                  <<-CODE
    sidepiece->eachSymmetry([](LateralSpec *symmetricDimer1) {
        Atom *atoms1[2] = { symmetricDimer1->atom(3), symmetricDimer1->atom(0) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricDimer1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{ab_ct}) && neighbours1[1]->is(#{ab_cr}))
            {
                BridgeCRs *bridgeCRs1 = neighbours1[1]->specByRole<BridgeCRs>(#{ab_cr});
                if (bridgeCRs1)
                {
                    BridgeCTs *bridgeCTs1 = neighbours1[0]->specByRole<BridgeCTs>(#{ab_ct});
                    if (bridgeCTs1)
                    {
                        SpecificSpec *targets[2] = { bridgeCRs1, bridgeCTs1 };
                        ChainFactory<
                            DuoLateralFactory,
                            ForwardDimerFormationNearBridgeEndLateral,
                            ForwardDimerFormationNearBridge
                        > factory(symmetricDimer1, targets);
                        factory.checkoutReactions<ForwardDimerFormationNearBridgeEndLateral>();
                    }
                }
            }
        });
    });
                  CODE
                end
              end
            end

            describe 'dimer drop near bridge' do
              it_behaves_like :check_code do
                let(:typical_reaction) { dept_dimer_drop_near_bridge }
                let(:lateral_reactions) do
                  [dept_end_lateral_ddnb, dept_middle_lateral_ddnb]
                end
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }

                let(:lateral_dimer) { sidepiece_spec_by_name(:dimer) }
                let(:spec) { lateral_dimer }

                let(:bwd_cc) { role(dept_bridge_with_dimer_base, :cr) }
                let(:bwd_cl) { role(dept_bridge_with_dimer_base, :cl) }

                let(:find_algorithm) do
                  <<-CODE
    sidepiece->eachSymmetry([](LateralSpec *symmetricDimer1) {
        Atom *atoms1[2] = { symmetricDimer1->atom(3), symmetricDimer1->atom(0) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricDimer1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{bwd_cl}) && neighbours1[1]->is(#{bwd_cc}))
            {
                if (neighbours1[0]->hasBondWith(neighbours1[1]))
                {
                    BridgeWithDimer *bridgeWithDimer1 = neighbours1[1]->specByRole<BridgeWithDimer>(#{bwd_cc});
                    if (bridgeWithDimer1)
                    {
                        BridgeWithDimer *bridgeWithDimer2 = neighbours1[0]->specByRole<BridgeWithDimer>(#{bwd_cl});
                        if (bridgeWithDimer2)
                        {
                            if (bridgeWithDimer1 == bridgeWithDimer2)
                            {
                                ChainFactory<
                                    UnoLateralFactory,
                                    ReverseDimerFormationNearBridgeEndLateral,
                                    ReverseDimerFormationNearBridge
                                > factory(symmetricDimer1, bridgeWithDimer2);
                                factory.checkoutReactions<ReverseDimerFormationNearBridgeEndLateral>();
                            }
                        }
                    }
                }
            }
        });
    });
                  CODE
                end
              end
            end

            describe 'symmetric incoherent dimer drop' do
              it_behaves_like :check_code do
                let(:typical_reaction) { dept_incoherent_dimer_drop }
                let(:lateral_reactions) { [dept_end_lateral_idd] }
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }

                let(:lateral_dimer) { sidepiece_spec_by_name(:dimer) }
                let(:spec) { lateral_dimer }
                let(:id_cr) { role(dept_twise_incoherent_dimer, :cr) }

                let(:find_algorithm) do
                  <<-CODE
    Atom *atoms1[2] = { sidepiece->atom(3), sidepiece->atom(0) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&sidepiece](Atom **neighbours1) {
        if (neighbours1[0]->is(#{id_cr}) && neighbours1[1]->is(#{id_cr}))
        {
            if (neighbours1[0]->hasBondWith(neighbours1[1]))
            {
                DimerCLiCRi *dimerCLiCRi1 = neighbours1[1]->specByRole<DimerCLiCRi>(#{id_cr});
                if (dimerCLiCRi1)
                {
                    DimerCLiCRi *dimerCLiCRi2 = neighbours1[0]->specByRole<DimerCLiCRi>(#{id_cr});
                    if (dimerCLiCRi2)
                    {
                        if (dimerCLiCRi1 == dimerCLiCRi2)
                        {
                            ChainFactory<
                                UnoLateralFactory,
                                ForwardIncoherentDimerDropEndLateral,
                                ForwardIncoherentDimerDrop
                            > factory(sidepiece, dimerCLiCRi2);
                            factory.checkoutReactions<ForwardIncoherentDimerDropEndLateral>();
                        }
                    }
                }
            }
        }
    });
                  CODE
                end
              end
            end

            describe 'many similar activated bridges' do
              let(:typical_reaction) { dept_symmetric_dimer_formation }
              let(:base_specs) { [dept_bridge_base] }

              let(:ab_ct) { role(dept_activated_bridge, :ct) }

              let(:front_bridge) { sidepiece_spec_related_by(position_100_front) }
              let(:cross_bridge) { sidepiece_spec_related_by(position_100_cross) }

              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = sidepiece->atom(0);
    eachNeighbour(atom1, &Diamond::cross_100, [&sidepiece](Atom *neighbour1) {
        if (neighbour1->is(1))
        {
            BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(1);
            if (bridgeCTs1)
            {
                ChainFactory<
                    UnoLateralFactory,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTs,
                    ForwardSymmetricDimerFormation
                > factory(sidepiece, bridgeCTs1);
                factory.checkoutReactions<
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTs,
                    #{small_name},
                    CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTsAnd100FrontBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs,
                    #{big_name},
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs
                >();
            }
        }
    });
    eachNeighbour(atom1, &Diamond::front_100, [&sidepiece](Atom *neighbour1) {
        if (neighbour1->is(1))
        {
            BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(1);
            if (bridgeCTs1)
            {
                ChainFactory<
                    UnoLateralFactory,
                    CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTs,
                    ForwardSymmetricDimerFormation
                > factory(sidepiece, bridgeCTs1);
                factory.checkoutReactions<
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTs,
                    #{small_name},
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs,
                    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs
                >();
            }
        }
    });
                CODE
              end

              describe 'one original lateral reaction ' do
                let(:spec) { front_bridge }

                it_behaves_like :check_code do
                  let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
                  let(:small_name) do
                    'ForwardSymmetricDimerFormationSmall'
                  end
                  let(:big_name) do
                    'CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs'
                  end
                end

                it_behaves_like :check_code do
                  let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
                  let(:small_name) do
                    'CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100FrontBridgeCTs'
                  end
                  let(:big_name) do
                    'ForwardSymmetricDimerFormationBig'
                  end
                end
              end

              describe 'many original lateral reactions' do
                let(:lateral_reactions) do
                  [dept_small_ab_lateral_sdf, dept_big_ab_lateral_sdf]
                end

                let(:small_name) do
                  'ForwardSymmetricDimerFormationSmall'
                end
                let(:big_name) do
                  'ForwardSymmetricDimerFormationBig'
                end

                it_behaves_like :check_code do
                  let(:spec) { front_bridge }
                end

                it_behaves_like :check_code do
                  let(:spec) { cross_bridge }
                end
              end
            end

            describe 'methyl incorporation near edge' do
              it_behaves_like :check_code do
                let(:typical_reaction) { dept_methyl_incorporation }
                let(:lateral_reactions) { [dept_de_lateral_mi] }
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
                end
                let(:specific_specs) do
                  [dept_activated_methyl_on_bridge, dept_activated_dimer]
                end

                let(:lateral_dimer) { sidepiece_spec_by_name(:dimer) }
                let(:spec) { lateral_dimer }

                let(:admr_cl) { role(dept_activated_dimer, :cl) }
                let(:admr_cr) { role(dept_activated_dimer, :cr) }
                let(:amob_cb) { role(dept_activated_methyl_on_bridge, :cb) }
                let(:amob_cm) { role(dept_activated_methyl_on_bridge, :cm) }

                let(:find_algorithm) do
                  <<-CODE
    sidepiece->eachSymmetry([](LateralSpec *symmetricDimer1) {
        Atom *atoms1[2] = { symmetricDimer1->atom(3), symmetricDimer1->atom(0) };
        eachNeighbour(atoms1[0], &Diamond::cross_110, [&atoms1, &symmetricDimer1](Atom *neighbour1) {
            if (neighbour1->is(#{admr_cl}))
            {
                DimerCRs *dimerCRs1 = neighbour1->specByRole<DimerCRs>(#{admr_cl});
                if (dimerCRs1)
                {
                    eachNeighbour(atoms1[1], &Diamond::cross_100, [&dimerCRs1, &symmetricDimer1](Atom *neighbour2) {
                        if (neighbour2->is(#{amob_cb}))
                        {
                            MethylOnBridgeCMs *methylOnBridgeCMs1 = neighbour2->specByRole<MethylOnBridgeCMs>(#{amob_cb});
                            if (methylOnBridgeCMs1)
                            {
                                SpecificSpec *targets[2] = { methylOnBridgeCMs1, dimerCRs1 };
                                ChainFactory<
                                    DuoLateralFactory,
                                    ForwardMethylIncorporationMiEdgeLateral,
                                    ForwardMethylIncorporation
                                > factory(symmetricDimer1, targets);
                                factory.checkoutReactions<ForwardMethylIncorporationMiEdgeLateral>();
                            }
                        }
                    });
                }
            }
        });
    });
                  CODE
                end
              end
            end
          end
        end

      end
    end
  end
end
