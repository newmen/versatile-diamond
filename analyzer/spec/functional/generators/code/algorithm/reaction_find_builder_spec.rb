require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionFindBuilder, type: :algorithm do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:generator) do
            bases = base_specs.dup
            specifics = specific_specs.dup

            append = -> spec { (spec.specific? ? specifics : bases) << spec }
            append[target_spec]
            append[other_spec] if respond_to?(:other_spec)

            stub_generator(
              base_specs: bases.uniq(&:name),
              specific_specs: specifics.uniq(&:name),
              typical_reactions: [subject])
          end

          let(:classifier) { generator.classifier }
          let(:code_reaction) { generator.reaction_class(subject.name) }
          let(:code_specie) { generator.specie_class(target_spec.name) }
          let(:builder) { described_class.new(generator, code_reaction, code_specie) }

          describe '#build' do
            Support::RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
              let(:"other_role_#{keyname}") { role(other_spec, keyname) }
            end

            it_behaves_like :check_code do
              subject { dept_methyl_activation }
              let(:target_spec) { dept_methyl_on_bridge_base }
              let(:find_algorithm) do
                <<-CODE
    create<ForwardMethylActivation>(target);
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_methyl_adsorption }
              let(:target_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    create<ForwardMethylAdsorption>(target);
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_methyl_desorption }
              let(:target_spec) { dept_incoherent_methyl_on_bridge }
              let(:find_algorithm) do
                <<-CODE
    create<ForwardMethylDesorption>(target);
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_sierpinski_drop }
              let(:target_spec) { dept_cross_bridge_on_bridges_base }
              let(:base_specs) { [dept_methyl_on_bridge_base] }
              let(:find_algorithm) do
                <<-CODE
    target->eachSymmetry([](SpecificSpec *symmetricCrossBridgeOnBridges1) {
        create<ForwardSierpinskiDrop>(symmetricCrossBridgeOnBridges1);
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_sierpinski_formation }
              let(:target_spec) { dept_activated_bridge }
              let(:other_spec) { dept_activated_methyl_on_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(0);
    eachNeighbour(atom1, &Diamond::cross_100, [&target](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cb}))
        {
            neighbour1->eachAmorphNeighbour([&target](Atom *amorph1) {
                if (amorph1->is(#{other_role_cm}))
                {
                    MethylOnBridgeCMs *methylOnBridgeCMs1 = amorph1->specByRole<MethylOnBridgeCMs>(#{other_role_cm});
                    SpecificSpec *targets[2] = { methylOnBridgeCMs1, target };
                    create<ReverseSierpinskiDrop>(targets);
                }
            });
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_sierpinski_formation }
              let(:target_spec) { dept_activated_methyl_on_bridge }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(1);
    eachNeighbour(atom1, &Diamond::cross_100, [&target](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_ct}))
        {
            BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
            SpecificSpec *targets[2] = { target, bridgeCTs1 };
            create<ReverseSierpinskiDrop>(targets);
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_incoherent_dimer_drop }
              let(:target_spec) { dept_twise_incoherent_dimer }
              let(:find_algorithm) do
                <<-CODE
    create<ForwardIncoherentDimerDrop>(target);
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_formation }
              let(:target_spec) { dept_activated_incoherent_bridge }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(0);
    eachNeighbour(atom1, &Diamond::front_100, [&target](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_ct}))
        {
            BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
            SpecificSpec *targets[2] = { target, bridgeCTs1 };
            create<ForwardDimerFormation>(targets);
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_formation }
              let(:target_spec) { dept_activated_bridge }
              let(:other_spec) { dept_activated_incoherent_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(0);
    eachNeighbour(atom1, &Diamond::front_100, [&target](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_ct}))
        {
            BridgeCTsi *bridgeCTsi1 = neighbour1->specByRole<BridgeCTsi>(#{other_role_ct});
            SpecificSpec *targets[2] = { bridgeCTsi1, target };
            create<ForwardDimerFormation>(targets);
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_intermed_migr_dc_formation }
              let(:target_spec) { dept_activated_bridge }
              let(:other_spec) { dept_activated_methyl_on_dimer }
              let(:find_algorithm) do
                <<-CODE
    target->eachSymmetry([](SpecificSpec *symmetricBridgeCTs1) {
        Atom *atom1 = symmetricBridgeCTs1->atom(2);
        eachNeighbour(atom1, &Diamond::cross_100, [&symmetricBridgeCTs1](Atom *neighbour1) {
            if (neighbour1->is(#{other_role_cr}))
            {
                neighbour1->eachAmorphNeighbour([&symmetricBridgeCTs1](Atom *amorph1) {
                    if (amorph1->is(#{other_role_cm}))
                    {
                        MethylOnDimerCMs *methylOnDimerCMs1 = amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm});
                        SpecificSpec *targets[2] = { methylOnDimerCMs1, symmetricBridgeCTs1 };
                        create<ForwardIntermedMigrDcFormation>(targets);
                    }
                });
            }
        });
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_intermed_migr_dc_formation }
              let(:target_spec) { dept_activated_methyl_on_dimer }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(1);
    eachNeighbour(atom1, &Diamond::cross_100, [&target](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cr}))
        {
            eachNeighbour(neighbour1, &Diamond::front_110, [&neighbour1, &target](Atom *neighbour2) {
                if (neighbour2->is(#{other_role_ct}))
                {
                    if (neighbour1->hasBondWith(neighbour2))
                    {
                        BridgeCTs *bridgeCTs1 = neighbour2->specByRole<BridgeCTs>(#{other_role_ct});
                        bridgeCTs1->eachSymmetry([&neighbour1, &target](SpecificSpec *symmetricBridgeCTs1) {
                            if (neighbour1 == symmetricBridgeCTs1->atom(2))
                            {
                                SpecificSpec *targets[2] = { target, symmetricBridgeCTs1 };
                                create<ForwardIntermedMigrDcFormation>(targets);
                            }
                        });
                    }
                }
            });
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_intermed_migr_dh_formation }
              let(:target_spec) { dept_activated_bridge }
              let(:other_spec) { dept_activated_methyl_on_dimer }
              let(:find_algorithm) do
                <<-CODE
    target->eachSymmetry([](SpecificSpec *symmetricBridgeCTs1) {
        Atom *atoms1[2] = { symmetricBridgeCTs1->atom(2), symmetricBridgeCTs1->atom(1) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricBridgeCTs1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cr}))
            {
                neighbours1[0]->eachAmorphNeighbour([&neighbours1, &symmetricBridgeCTs1](Atom *amorph1) {
                    if (amorph1->is(#{other_role_cm}))
                    {
                        MethylOnDimerCMs *methylOnDimerCMs1 = amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm});
                        if (neighbours1[1] != methylOnDimerCMs1->atom(4))
                        {
                            SpecificSpec *targets[2] = { methylOnDimerCMs1, symmetricBridgeCTs1 };
                            create<ForwardIntermedMigrDhFormation>(targets);
                        }
                    }
                });
            }
        });
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_intermed_migr_dh_formation }
              let(:target_spec) { dept_activated_methyl_on_dimer }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { target->atom(1), target->atom(4) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&target](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}))
        {
            eachNeighbour(neighbours1[0], &Diamond::front_110, [&neighbours1, &target](Atom *neighbour1) {
                if (neighbour1->is(#{other_role_ct}))
                {
                    if (neighbours1[0]->hasBondWith(neighbour1))
                    {
                        BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
                        bridgeCTs1->eachSymmetry([&neighbours1, &target](SpecificSpec *symmetricBridgeCTs1) {
                            if (neighbours1[1] != symmetricBridgeCTs1->atom(1))
                            {
                                if (neighbours1[0] == symmetricBridgeCTs1->atom(2))
                                {
                                    SpecificSpec *targets[2] = { target, symmetricBridgeCTs1 };
                                    create<ForwardIntermedMigrDhFormation>(targets);
                                }
                            }
                        });
                    }
                }
            });
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_intermed_migr_df_formation }
              let(:target_spec) { dept_activated_bridge }
              let(:other_spec) { dept_activated_methyl_on_dimer }
              let(:find_algorithm) do
                <<-CODE
    target->eachSymmetry([](SpecificSpec *symmetricBridgeCTs1) {
        Atom *atoms1[2] = { symmetricBridgeCTs1->atom(2), symmetricBridgeCTs1->atom(1) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricBridgeCTs1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cl}))
            {
                if (neighbours1[0]->hasBondWith(neighbours1[1]))
                {
                    neighbours1[0]->eachAmorphNeighbour([&symmetricBridgeCTs1](Atom *amorph1) {
                        if (amorph1->is(#{other_role_cm}))
                        {
                            MethylOnDimerCMs *methylOnDimerCMs1 = amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm});
                            SpecificSpec *targets[2] = { methylOnDimerCMs1, symmetricBridgeCTs1 };
                            create<ForwardIntermedMigrDfFormation>(targets);
                        }
                    });
                }
            }
        });
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_intermed_migr_df_formation }
              let(:target_spec) { dept_activated_methyl_on_dimer }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *anchors[2] = { target->atom(1), target->atom(4) };
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
        {
            neighbourFrom(neighbours1, &Diamond::front_110_at, [&](Atom *neighbour1) {
                if (neighbour1->is(#{other_role_ct}) && neighbours1[0]->hasBondWith(neighbour1) && neighbours1[1]->hasBondWith(neighbour1))
                {
                    BridgeCTs *specie1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
                    specie1->eachSymmetry([&](SpecificSpec *specie2) {
                        if (specie2->atom(2) == neighbours1[0] && specie2->atom(1) == neighbours1[1])
                        {
                            SpecificSpec *targets[2] = { target, specie2 };
                            create<ForwardIntermedMigrDfFormation>(targets);
                        }
                    });
                }
            });
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_methyl_incorporation }
              let(:target_spec) { dept_activated_methyl_on_bridge }
              let(:other_spec) { dept_activated_dimer }
              let(:find_algorithm) do
                <<-CODE
    target->eachSymmetry([](SpecificSpec *specie1) {
        Atom *anchors[2] = { specie1->atom(3), specie1->atom(2) };
        eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cl}) && neighbours1[1]->is(#{other_role_cr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
            {
                DimerCRs *specie2 = neighbours1[1]->specByRole<DimerCRs>(#{other_role_cr});
                SpecificSpec *targets[2] = { specie2, specie1 };
                create<ForwardMethylIncorporation>(targets);
            }
        });
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
              subject { dept_methyl_incorporation }
              let(:target_spec) { dept_activated_dimer }
              let(:other_spec) { dept_activated_methyl_on_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *anchors[2] = { target->atom(3), target->atom(0) };
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
        {
            neighbourFrom(neighbours1, &Diamond::front_110_at, [&](Atom *neighbour1) {
                if (neighbour1->is(#{other_role_cb}) && neighbours1[0]->hasBondWith(neighbour1) && neighbours1[1]->hasBondWith(neighbour1))
                {
                    neighbour1->eachAmorphNeighbour([&](Atom *amorph1) {
                        if (amorph1->is(#{other_role_cm}))
                        {
                            MethylOnBridgeCMs *specie1 = amorph1->specByRole<MethylOnBridgeCMs>(#{other_role_cm});
                            specie1->eachSymmetry([](SpecificSpec *specie2) {
                                if (specie2->atom(2) == neighbours1[1] && specie2->atom(3) == neighbours1[0])
                                {
                                    SpecificSpec *targets[2] = { target, specie2 };
                                    create<ForwardMethylIncorporation>(targets);
                                }
                            });
                        }
                    });
                }
            });
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base] }
              subject { dept_methyl_to_gap }
              let(:target_spec) { dept_extra_activated_methyl_on_bridge }
              let(:other_spec) { dept_right_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *anchors[2] = { target->atom(2), target->atom(3) };
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
        {
            BridgeCRs *specie1 = neighbours1[0]->specByRole<BridgeCRs>(#{other_role_cr});
            if (specie1->atom(1) != neighbours1[1])
            {
                BridgeCRs *specie2 = neighbours1[1]->specByRole<BridgeCRs>(#{other_role_cr});
                if (specie2->atom(1) != neighbours1[0])
                {
                    SpecificSpec *targets[3] = { target, specie1, specie2 };
                    create<ForwardMethylToGap>(targets);
                }
            }
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
              subject { dept_methyl_to_gap }
              let(:target_spec) { dept_right_activated_bridge }
              let(:other_spec) { dept_extra_activated_methyl_on_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *anchor = target->atom(2);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (target->atom(1) != neighbour1 && neighbour1->is(#{role_cr}))
        {
            BridgeCRs *specie1 = neighbour1->specByRole<BridgeCRs>(#{role_cr});
            if (specie1->atom(1) != anchor)
            {
                Atom *anchors1[2] = { neighbour1, anchor };
                eachNeighbours<2>(anchors1, &Diamond::cross_100, [&](Atom **neighbours1) {
                    if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
                    {
                        neighbourFrom(neighbours1, &Diamond::front_110_at, [&](Atom *neighbour2) {
                            if (neighbour2->is(#{other_role_cb}) && neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                            {
                                neighbour2->eachAmorphNeighbour([&](Atom *amorph1) {
                                    if (amorph1->is(#{other_role_cm}))
                                    {
                                        MethylOnBridgeCMss *specie2 = amorph1->specByRole<MethylOnBridgeCMss>(#{other_role_cm});
                                        SpecificSpec *targets[3] = { specie2, specie1, target };
                                        create<ForwardMethylToGap>(targets);
                                    }
                                });
                            }
                        });
                    }
                });
            }
        }
    });
                CODE
              end
            end

            describe 'two level dimers formation' do
              Support::RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
                let(:"thrid_role_#{keyname}") { role(thrid_spec, keyname) }
              end

              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
              end
              subject { dept_two_side_dimers_formation }

              it_behaves_like :check_code do
                let(:target_spec) { dept_right_activated_bridge }
                let(:other_spec) { dept_activated_incoherent_dimer }
                let(:thrid_spec) { dept_extra_activated_methyl_on_bridge }
                let(:find_algorithm) do
                  <<-CODE
    Atom *anchor = target->atom(2);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cl}))
        {
            DimerCLsCRi *specie1 = neighbour1->specByRole<DimerCLsCRi>(#{other_role_cl});
            Atom *anchors1[2] = { neighbour1, anchor };
            eachNeighbours<2>(anchors1, &Diamond::cross_100, [&](Atom **neighbours1) {
                if (neighbours1[0]->is(#{thrid_role_cr}) && neighbours1[1]->is(#{thrid_role_cr}))
                {
                    neighbourFrom(neighbours1, &Diamond::front_110_at, [&](Atom *neighbour2) {
                        if (neighbour2->is(#{thrid_role_cb}) && neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                        {
                            neighbour2->eachAmorphNeighbour([&](Atom *amorph1) {
                                if (amorph1->is(#{thrid_role_cm}))
                                {
                                    MethylOnBridgeCMss *specie2 = amorph1->specByRole<MethylOnBridgeCMss>(#{thrid_role_cm});
                                    specie2->eachSymmetry([](SpecificSpec *specie3) {
                                    if (specie3->atom(2) == neighbours1[1] && specie3->atom(3) == neighbours1[0])
                                    {
                                        SpecificSpec *targets[3] = { specie1, specie3, target };
                                        create<ForwardTwoSideDimersForm>(targets);
                                    }
                                }
                            });
                        }
                    });
                }
            });
        }
    });
                  CODE
                end
              end

              it_behaves_like :check_code do
                let(:target_spec) { dept_activated_incoherent_dimer }
                let(:other_spec) { dept_right_activated_bridge }
                let(:thrid_spec) { dept_extra_activated_methyl_on_bridge }
                let(:find_algorithm) do
                  <<-CODE
    Atom *anchor = target->atom(3);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cr}))
        {
            BridgeCRs *specie1 = neighbour1->specByRole<BridgeCRs>(#{other_role_cr});
            Atom *anchors1[2] = { anchor, neighbour1 };
            eachNeighbours<2>(anchors1, &Diamond::cross_100, [&](Atom **neighbours1) {
                if (neighbours1[0]->is(#{thrid_role_cr}) && neighbours1[1]->is(#{thrid_role_cr}))
                {
                    neighbourFrom(neighbours1, Diamond::front_110_at, [&](Atom *neighbour2) {
                        if (neighbour2->is(#{thrid_role_cb}) && neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                        {
                            neighbour2->eachAmorphNeighbour([&](Atom *amorph1) {
                                if (amorph1->is(#{thrid_role_cm}))
                                {
                                    MethylOnBridgeCMss *specie2 = amorph1->specByRole<MethylOnBridgeCMss>(#{thrid_role_cm});
                                    specie2->eachSymmetry([](SpecificSpec *specie3) {
                                    if (specie3->atom(2) == neighbours1[1] && specie3->atom(3) == neighbours1[0])
                                    {
                                        SpecificSpec *targets[3] = { target, specie3, specie1 };
                                        create<ForwardTwoDimersForm>(targets);
                                    }
                                }
                            });
                        }
                    });
                }
            });
        }
    });
                  CODE
                end
              end

              it_behaves_like :check_code do
                let(:target_spec) { dept_extra_activated_methyl_on_bridge }
                let(:other_spec) { dept_activated_incoherent_dimer }
                let(:thrid_spec) { dept_right_activated_bridge }
                let(:find_algorithm) do
                  <<-CODE
    target->eachSymmetry([](SpecificSpec *specie1) {
        Atom *anchors[2] = { specie1->atom(2), specie1->atom(3) };
        eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cl}) && neighbours1[1]->is(#{thrid_role_cr}))
            {
                DimerCLsCRi *specie2 = neighbours1[0]->specByRole<DimerCLsCRi>(#{other_role_cl});
                BridgeCRs *specie3 = neighbours1[1]->specByRole<BridgeCRs>(#{thrid_role_cr});
                SpecificSpec *targets[3] = { specie2, specie1, specie3 };
                create<ForwardTwoDimersForm>(targets);
            }
        });
    });
                  CODE
                end
              end
            end

            it_behaves_like :check_code do
              subject { dept_hydrogen_abs_from_gap }
              let(:target_spec) { dept_right_hydrogenated_bridge }
              let(:other_spec) { target_spec }
              let(:find_algorithm) do
                <<-CODE
    Atom *anchor = target->atom(2);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (target->atom(1) != neighbour1 && neighbour1->is(#{role_cr}))
        {
            BridgeCRH *specie1 = neighbour1->specByRole<BridgeCRH>(#{role_cr});
            if (specie1->atom(1) != anchor)
            {
                SpecificSpec *targets[2] = { target, specie1 };
                create<ForwardHydrogenAbsFromGap>(targets);
            }
        }
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
