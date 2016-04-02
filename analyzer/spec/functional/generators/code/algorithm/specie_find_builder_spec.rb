require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SpecieFindBuilder, type: :algorithm do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:typical_reactions) { [] }
          let(:generator) do
            stub_generator(
              base_specs: base_specs,
              specific_specs: specific_specs,
              typical_reactions: typical_reactions)
          end
          let(:classifier) { generator.classifier }

          let(:code_specie) { generator.specie_class(subject.name) }
          let(:builder) { code_specie.find_builder }

          describe '#build' do
            [:ct, :cr].each do |keyname|
              let(:"b_#{keyname}") { role(dept_bridge_base, keyname) }
            end
            [:cb, :cm].each do |keyname|
              let(:"mob_#{keyname}") { role(dept_methyl_on_bridge_base, keyname) }
            end
            let(:d_cr) { role(dept_dimer_base, :cr) }

            it_behaves_like :check_code do
              subject { dept_bridge_base }
              let(:base_specs) { [subject, dept_dimer_base] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_ct}))
    {
        if (!anchor->hasRole(BRIDGE, #{role_ct}))
        {
            allNeighbours(anchor, &Diamond::cross_110, [&](Atom **neighbours1) {
                if (neighbours1[0]->is(#{role_cr}) && neighbours1[1]->is(#{role_cr}))
                {
                    if (anchor->hasBondWith(neighbours1[0]) && anchor->hasBondWith(neighbours1[1]))
                    {
                        Atom *atoms1[3] = { anchor, neighbours1[0], neighbours1[1] };
                        create<Bridge>(atoms1);
                    }
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_right_hydrogenated_bridge }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }
              let(:find_algorithm) do
                <<-CODE
    parent->eachSymmetry([](ParentSpec *bridge1) {
        Atom *atom1 = bridge1->atom(2);
        if (atom1->is(#{role_cr}))
        {
            if (!atom1->hasRole(BRIDGE_CRH, #{role_cr}))
            {
                create<BridgeCRH>(bridge1);
            }
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:typical_reactions) { [dept_methyl_deactivation] }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = parent->atom(0);
    if (atom1->is(#{role_cb}))
    {
        if (!atom1->checkAndFind(METHYL_ON_BRIDGE, #{role_cb}))
        {
            atom1->eachAmorphNeighbour([&parent](Atom *amorph1) {
                if (amorph1->is(#{role_cm}))
                {
                    create<MethylOnBridge>(amorph1, parent);
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_activated_methyl_on_incoherent_bridge }
              let(:base_specs) { [dept_methyl_on_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { parent->atom(0), parent->atom(1) };
    if (atoms1[0]->is(#{role_cm}) && atoms1[1]->is(#{role_cb}))
    {
        if (!atoms1[1]->hasRole(METHYL_ON_BRIDGE_CBi_CMs, #{role_cb}) || !atoms1[0]->hasRole(METHYL_ON_BRIDGE_CBi_CMs, #{role_cm}))
        {
            create<MethylOnBridgeCBiCMs>(parent);
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_high_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = parent->atom(0);
    if (atom1->is(#{role_cb}))
    {
        if (!atom1->hasRole(HIGH_BRIDGE, #{role_cb}))
        {
            atom1->eachAmorphNeighbour([&parent](Atom *amorph1) {
                if (amorph1->is(#{role_cm}))
                {
                    create<HighBridge>(amorph1, parent);
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_vinyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = parent->atom(0);
    if (atom1->is(#{role_cb}))
    {
        if (!atom1->hasRole(VINYL_ON_BRIDGE, #{role_cb}))
        {
            atom1->eachAmorphNeighbour([&](Atom *amorph1) {
                if (amorph1->is(#{role_c1}))
                {
                    amorph1->eachAmorphNeighbour([&](Atom *amorph2) {
                        if (amorph2->is(#{role_c2}))
                        {
                            Atom *additionalAtoms[2] = { amorph1, amorph2 };
                            create<VinylOnBridge>(additionalAtoms, parent);
                        }
                    });
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(DIMER, #{role_cr}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                if (neighbour1->is(#{role_cr}))
                {
                    if (anchor->hasBondWith(neighbour1))
                    {
                        Bridge *bridge2 = neighbour1->specByRole<Bridge>(#{b_ct});
                        ParentSpec *parents[2] = { bridge1, bridge2 };
                        create<Dimer>(parents);
                    }
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_methyl_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER, #{role_cr}))
        {
            MethylOnBridge *methylOnBridge1 = anchor->specByRole<MethylOnBridge>(#{mob_cb});
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                if (neighbour1->is(#{role_cl}))
                {
                    if (anchor->hasBondWith(neighbour1))
                    {
                        Bridge *bridge1 = neighbour1->specByRole<Bridge>(#{b_ct});
                        ParentSpec *parents[2] = { methylOnBridge1, bridge1 };
                        create<MethylOnDimer>(parents);
                    }
                }
            });
        }
    }
    if (anchor->is(#{role_cl}))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER, #{role_cl}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                if (neighbour1->is(#{role_cr}))
                {
                    if (anchor->hasBondWith(neighbour1))
                    {
                        MethylOnBridge *methylOnBridge1 = neighbour1->specByRole<MethylOnBridge>(#{mob_cb});
                        ParentSpec *parents[2] = { methylOnBridge1, bridge1 };
                        create<MethylOnDimer>(parents);
                    }
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_two_methyls_on_dimer_base }
              let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { parent->atom(0), parent->atom(3) };
    if (atoms1[0]->is(#{role_cr}) && atoms1[1]->is(#{role_cl}))
    {
        if (!atoms1[0]->hasRole(TWO_METHYLS_ON_DIMER, #{role_cr}) || !atoms1[1]->hasRole(TWO_METHYLS_ON_DIMER, #{role_cl}))
        {
            atoms1[0]->eachAmorphNeighbour([&](Atom *amorph1) {
                if (amorph1->is(#{role_c1}))
                {
                    atoms1[1]->eachAmorphNeighbour([&](Atom *amorph2) {
                        if (amorph2->is(#{role_c2}))
                        {
                            Atom *additionalAtoms[2] = { amorph1, amorph2 };
                            create<TwoMethylsOnDimer>(additionalAtoms, parent);
                        }
                    });
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_cross_bridge_on_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_ctr}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_BRIDGES, #{role_ctr}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            anchor->eachAmorphNeighbour([&](Atom *amorph1) {
                if (amorph1->is(#{role_cm}))
                {
                    eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour1) {
                        if (neighbour1->is(#{role_ctr}))
                        {
                            Bridge *bridge2 = neighbour1->specByRole<Bridge>(#{b_ct});
                            if (neighbour1->hasBondWith(amorph1))
                            {
                                ParentSpec *parents[2] = { bridge1, bridge2 };
                                create<CrossBridgeOnBridges>(amorph1, parents);
                            }
                        }
                    });
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_cross_bridge_on_bridges_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:typical_reactions) { [dept_sierpinski_drop] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_BRIDGES, #{role_cm}))
        {
            anchor->eachSpecsPortionByRole<MethylOnBridge>(#{mob_cm}, 2, [&](MethylOnBridge **species1) {
                Atom *atoms[2] = { species1[0]->atom(1), species1[1]->atom(1) };
                eachNeighbour(atoms[0], &Diamond::cross_100, [&](Atom *neighbour1) {
                    if (atoms[1] == neighbour1)
                    {
                        ParentSpec *parents[2] = { species1[0], species1[1] };
                        create<CrossBridgeOnBridges>(parents);
                    }
                });
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_cross_bridge_on_dimers_base }
              let(:base_specs) do
                [dept_bridge_base, dept_dimer_base, subject]
              end

              let(:mod_cm) { role(dept_methyl_on_dimer_base, :cm) }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_ctl}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_DIMERS, #{role_ctl}))
        {
            Dimer *specie1 = anchor->specByRole<Dimer>(#{d_cr});
            Atom *anchors[2] = { anchor, specie1->atom(0) };
            anchors[0]->eachAmorphNeighbour([&](Atom *amorph1) {
                if (amorph1->is(#{role_cm}))
                {
                    eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
                        if (neighbours1[0]->is(#{role_ctr}) && neighbours1[1]->is(#{role_csr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
                        {
                            Dimer *specie2 = neighbours1[1]->specByRole<Dimer>(#{d_cr});
                            if (neighbours1[0]->hasBondWith(amorph1))
                            {
                                ParentSpec *parents[2] = { specie1, specie2 };
                                create<CrossBridgeOnDimers>(amorph1, parents);
                            }
                        }
                    });
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_cross_bridge_on_dimers_base }
              let(:base_specs) do
                [dept_bridge_base, dept_dimer_base, dept_methyl_on_dimer_base, subject]
              end

              let(:mod_cm) { role(dept_methyl_on_dimer_base, :cm) }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_DIMERS, #{role_cm}))
        {
            anchor->eachSpecsPortionByRole<MethylOnBridge>(#{mod_cm}, 2, [&](MethylOnDimer **species1) {
                Atom *atoms[4] = { species1[0]->atom(4), species1[0]->atom(1), species1[1]->atom(4), species1[1]->atom(1) };
                Atom *anchors[2] = { atoms[3], atoms[2] };
                eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
                    if (atoms[1] == neighbours1[0] && atoms[0] == neighbours1[1] && neighbours1[0]->hasBondWith(neighbours1[1]))
                    {
                        ParentSpec *parents[2] = { species1[0], species1[1] };
                        create<CrossBridgeOnDimers>(parents);
                    }
                });
            }
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_three_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cc}))
    {
        if (!anchor->hasRole(THREE_BRIDGES, #{role_cc}))
        {
            anchor->eachSpecsPortionByRole<Bridge>(#{b_cr}, 2, [&](Bridge **species1) {
                for (uint se = 0; se < 2; ++se)
                {
                    Atom *atom1 = species1[se]->atom(2);
                    ParentSpec *specie1 = atom1->specByRole<Bridge>(#{b_ct});
                    ParentSpec *parents[3] = { species1[se], species1[1-se], specie1 };
                    create<ThreeBridges>(parents);
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_bridge_with_dimer_base }
              let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(BRIDGE_WITH_DIMER, #{role_cr}))
        {
            anchor->eachSpecByRole<Dimer>(#{d_cr}, [&](Dimer *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (specie1->atom(0) == anchor)
                    {
                        anchor->eachSpecByRole<Bridge>(#{b_cr}, [&](Bridge *target2) {
                            target2->eachSymmetry([&](ParentSpec *specie2) {
                                if (specie2->atom(1) == anchor)
                                {
                                    Atom *atom1 = specie2->atom(2);
                                    ParentSpec *specie3 = atom1->specByRole<Bridge>(#{b_ct});
                                    ParentSpec *parents[3] = { specie1, specie2, specie3 };
                                    create<BridgeWithDimer>(parents);
                                }
                            });
                        });
                    }
                });
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_top_methyl_on_half_extended_bridge_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:typical_reactions) { [dept_sierpinski_drop] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_ct}))
    {
        if (!anchor->hasRole(TOP_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_ct}))
        {
            MethylOnBridge *specie1 = anchor->specByRole<MethylOnBridge>(#{role_ct});
            specie1->eachSymmetry([&](ParentSpec *specie2) {
                Atom *atom1 = specie2->atom(3);
                Bridge *specie3 = atom1->specByRole<Bridge>(#{b_ct});
                ParentSpec *parents[2] = { specie2, specie3 };
                create<TopMethylOnHalfExtendedBridge>(parents);
            });
        }
    }
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(TOP_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            Bridge *specie1 = anchor->specByRole<Bridge>(#{b_ct});
            eachNeighbour(anchor, &Diamond::front_110, [&](Atom *neighbour1) {
                if (neighbour1->is(#{role_ct}) && anchor->hasBondWith(neighbour1))
                {
                    MethylOnBridge *specie2 = neighbour1->specByRole<MethylOnBridge>(#{role_ct});
                    specie2->eachSymmetry([&](ParentSpec *specie3) {
                        ParentSpec *parents[2] = { specie3, specie1 };
                        create<TopMethylOnHalfExtendedBridge>(parents);
                    });
                }
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_lower_methyl_on_half_extended_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cbr}))
    {
        if (!anchor->hasRole(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cbr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cbr}, [&](Bridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (anchor == specie1->atom(2))
                    {
                        Atom *atom1 = specie1->atom(0);
                        anchor->eachAmorphNeighbour([&](Atom *amorph1) {
                            if (amorph1->is(#{role_cm}))
                            {
                                Bridge *specie2 = atom1->eachSpecByRole<Bridge>(#{b_ct}, [&](Bridge *target1) {
                                    target1->eachSymmetry([&](ParentSpec *specie3) {
                                        if (specie3->atom(2) == atom1)
                                        {
                                            ParentSpec *parents[2] = { specie3, specie1 };
                                            create<LowerMethylOnHalfExtendedBridge>(amorph1, parents);
                                        }
                                    });
                                });
                            }
                        });
                    }
                });
            });
        }
    }
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (specie1->atom(2) == anchor)
                    {
                        Bridge *specie2 = anchor->specByRole<Bridge>(#{b_ct});
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atom1 = specie3->atom(1);
                            if (atom1->is(#{role_cbr}))
                            {
                                atom1->eachAmorphNeighbour([&](Atom *amorph1) {
                                    if (amorph1->is(#{role_cm}))
                                    {
                                        ParentSpec *parents[2] = { specie3, specie1 };
                                        create<LowerMethylOnHalfExtendedBridge>(amorph1, parents);
                                    }
                                });
                            }
                        });
                    }
                });
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_lower_methyl_on_half_extended_bridge_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_right_bridge_base, subject]
              end
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cbr}))
    {
        if (!anchor->hasRole(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cbr}))
        {
            MethylOnRightBridge *specie1 = anchor->specByRole<MethylOnRightBridge>(#{role_cbr});
            Atom *atom1 = specie1->atom(1);
            if (atom1->is(#{role_cr})) {
                atom1->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *target1) {
                    target1->eachSymmetry([&](ParentSpec *specie2) {
                        if (atom1 == specie2->atom(2))
                        {
                            ParentSpec *parents[2] = { specie1, specie2 };
                            create<LowerMethylOnHalfExtendedBridge>(parents);
                        }
                    });
                });
            }
        }
    }
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (specie1->atom(2) == anchor)
                    {
                        eachNeighbour(anchor, &Diamond::cross_110, [&](Atom *neighbour1) {
                            if (neighbour1->is(#{role_cbr}) && anchor->hasBondWith(neighbour1))
                            {
                                MethylOnRightBridge *specie2 = neighbour1->specByRole<MethylOnRightBridge>(#{role_cbr});
                                ParentSpec *parents[2] = { specie2, specie1 };
                                create<LowerMethylOnHalfExtendedBridge>(parents);
                            }
                        });
                    }
                });
            });
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_intermed_migr_down_bridge_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_BRIDGE, #{role_cm}))
        {
            anchor->eachSpecsPortionByRole<MethylOnBridge>(#{mob_cm}, 2, [&](MethylOnBridge **species1) {
                species1[0]->eachSymmetry([&](ParentSpec *specie1) {
                    Atom *atom1 = specie1->atom(2);
                    Atom *atom2 = species1[1]->atom(1);
                    eachNeighbour(atom1, &Diamond::cross_100, [&](Atom *neighbour1) {
                        if (atom2 == neighbour1)
                        {
                            ParentSpec *parents[2] = { specie1, species1[1] };
                            create<IntermedMigrDownBridge>(parents);
                        }
                    });
                });
            });
        }
    }
                CODE
              end
            end

            describe 'intermediate migration down species' do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  subject
                ]
              end
              let(:mod_cm) { role(dept_methyl_on_dimer_base, :cm) }

              it_behaves_like :check_code do
                subject { dept_intermed_migr_down_common_base }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cdr}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_COMMON, #{role_cdr}))
        {
            MethylOnDimer *specie1 = anchor->specByRole<MethylOnDimer>(#{role_cdr});
            Atom *atom1 = specie1->atom(0);
            if (atom1->is(#{role_cm}))
            {
                atom1->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie2) {
                    if (specie2->atom(1) != anchor)
                    {
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atom2 = specie3->atom(2);
                            eachNeighbour(atom2, &Diamond::cross_100, [&](Atom *neighbour1) {
                                if (neighbour1 == anchor)
                                {
                                    ParentSpec *parents[2] = { specie1, specie3 };
                                    create<IntermedMigrDownCommon>(parents);
                                }
                            });
                        });
                    }
                });
            }
        }
    }
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_COMMON, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie1) {
                specie1->eachSymmetry([&](ParentSpec *specie2) {
                    Atom *atom1 = specie2->atom(2);
                    eachNeighbour(atom1, &Diamond::cross_100, [&](Atom *neighbour1) {
                        if (neighbour1->is(#{role_cdr}))
                        {
                            MethylOnDimer *specie3 = neighbour1->specByRole<MethylOnDimer>(#{role_cdr});
                            if (specie3->atom(0) == anchor)
                            {
                                ParentSpec *parents[2] = { specie3, specie2 };
                                create<IntermedMigrDownCommon>(parents);
                            }
                        }
                    });
                });
            });
        }
    }
                  CODE
                end
              end

              it_behaves_like :check_code do
                subject { dept_intermed_migr_down_half_base }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cdr}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_HALF, #{role_cdr}))
        {
            MethylOnDimer *specie1 = anchor->specByRole<MethylOnDimer>(#{role_cdr});
            Atom *atom1 = specie1->atom(0);
            Atom *atom2 = specie1->atom(4);
            if (atom1->is(#{role_cm}))
            {
                atom1->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie2) {
                    if (specie2->atom(1) != anchor)
                    {
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atom3 = specie3->atom(2);
                            Atom *atom4 = specie3->atom(3);
                            Atom *atoms1[2] = { atom3, atom4 };
                            eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
                                if (neighbours1[0] == anchor && neighbours1[1] != atom2)
                                {
                                    ParentSpec *parents[2] = { specie1, specie3 };
                                    create<IntermedMigrDownHalf>(parents);
                                }
                            });
                        });
                    }
                });
            }
        }
    }
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_HALF, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie1) {
                specie1->eachSymmetry([&](ParentSpec *specie2) {
                    Atom *atom1 = specie2->atom(2);
                    Atom *atom2 = specie2->atom(3);
                    Atom *atoms1[2] = { atom1, atom2 };
                    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
                        if (neighbours1[0]->is(#{role_cdr}))
                        {
                            MethylOnDimer *specie3 = neighbours1[0]->specByRole<MethylOnDimer>(#{role_cdr});
                            if (specie3->atom(0) == anchor && specie3->atom(4) != neighbours1[1])
                            {
                                ParentSpec *parents[2] = { specie3, specie2 };
                                create<IntermedMigrDownHalf>(parents);
                            }
                        }
                    });
                });
            });
        }
    }
                  CODE
                end
              end

              it_behaves_like :check_code do
                subject { dept_intermed_migr_down_full_base }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cdr}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_FULL, #{role_cdr}))
        {
            MethylOnDimer *specie1 = anchor->specByRole<MethylOnDimer>(#{role_cdr});
            Atom *atom1 = specie1->atom(0);
            Atom *atom2 = specie1->atom(4);
            if (atom1->is(#{role_cm}))
            {
                atom1->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie2) {
                    if (specie2->atom(1) != anchor)
                    {
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atom3 = specie3->atom(2);
                            Atom *atom4 = specie3->atom(3);
                            Atom *atoms1[2] = { atom3, atom4 };
                            eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
                                if (neighbours1[0] == anchor && neighbours1[1] == atom2 && neighbours1[0]->hasBondWith(neighbours1[1]))
                                {
                                    ParentSpec *parents[2] = { specie1, specie3 };
                                    create<IntermedMigrDownFull>(parents);
                                }
                            });
                        });
                    }
                });
            }
        }
    }
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_FULL, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie1) {
                specie1->eachSymmetry([&](ParentSpec *specie2) {
                    Atom *atom1 = specie2->atom(2);
                    Atom *atom2 = specie2->atom(3);
                    Atom *atoms1[2] = { atom1, atom2 };
                    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
                        if (neighbours1[0]->is(#{role_cdr}) && neighbours1[1]->is(#{role_cdl}) && neighbours1[0]->hasBondWith(neighbours1[1]))
                        {
                            MethylOnDimer *specie3 = neighbours1[0]->specByRole<MethylOnDimer>(#{role_cdr});
                            if (specie3->atom(0) == anchor && specie3->atom(4) == neighbours1[1])
                            {
                                ParentSpec *parents[2] = { specie3, specie2 };
                                create<IntermedMigrDownFull>(parents);
                            }
                        }
                    });
                });
            });
        }
    }
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
