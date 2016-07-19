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
            let(:mod_cm) { role(dept_methyl_on_dimer_base, :cm) }
            let(:vob) { role(dept_vinyl_on_bridge_base, :c1) }

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
    parent->eachSymmetry([](ParentSpec *symmetricBridge1) {
        Atom *atom1 = symmetricBridge1->atom(2);
        if (atom1->is(#{role_cr}))
        {
            if (!atom1->hasRole(BRIDGE_CRH, #{role_cr}))
            {
                create<BridgeCRH>(symmetricBridge1);
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
    Atom *atoms1[2] = { parent->atom(1), parent->atom(0) };
    if (atoms1[0]->is(#{role_cb}) && atoms1[1]->is(#{role_cm}))
    {
        if (!atoms1[0]->hasRole(METHYL_ON_BRIDGE_CBi_CMs, #{role_cb}) || !atoms1[1]->hasRole(METHYL_ON_BRIDGE_CBi_CMs, #{role_cm}))
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
            atom1->eachAmorphNeighbour([&parent](Atom *amorph1) {
                if (amorph1->is(#{role_c1}))
                {
                    amorph1->eachAmorphNeighbour([&amorph1, &parent](Atom *amorph2) {
                        if (amorph2->is(#{role_c2}))
                        {
                            Atom *additionalAtoms[2] = { amorph2, amorph1 };
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
            if (bridge1)
            {
                eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_cr}))
                    {
                        if (anchor->hasBondWith(neighbour1))
                        {
                            Bridge *bridge2 = neighbour1->specByRole<Bridge>(#{b_ct});
                            if (bridge2)
                            {
                                ParentSpec *parents[2] = { bridge1, bridge2 };
                                create<Dimer>(parents);
                            }
                        }
                    }
                });
            }
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
            if (methylOnBridge1)
            {
                eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_cl}))
                    {
                        if (anchor->hasBondWith(neighbour1))
                        {
                            Bridge *bridge1 = neighbour1->specByRole<Bridge>(#{b_ct});
                            if (bridge1)
                            {
                                ParentSpec *parents[2] = { methylOnBridge1, bridge1 };
                                create<MethylOnDimer>(parents);
                            }
                        }
                    }
                });
            }
        }
    }
    if (anchor->is(#{role_cl}))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER, #{role_cl}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            if (bridge1)
            {
                eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_cr}))
                    {
                        if (anchor->hasBondWith(neighbour1))
                        {
                            MethylOnBridge *methylOnBridge1 = neighbour1->specByRole<MethylOnBridge>(#{mob_cb});
                            if (methylOnBridge1)
                            {
                                ParentSpec *parents[2] = { methylOnBridge1, bridge1 };
                                create<MethylOnDimer>(parents);
                            }
                        }
                    }
                });
            }
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_vinyl_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_vinyl_on_bridge_base, subject]
              end
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(VINYL_ON_DIMER, #{role_cr}))
        {
            VinylOnBridge *vinylOnBridge1 = anchor->specByRole<VinylOnBridge>(#{mob_cb});
            if (vinylOnBridge1)
            {
                eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_cl}))
                    {
                        if (anchor->hasBondWith(neighbour1))
                        {
                            Bridge *bridge1 = neighbour1->specByRole<Bridge>(#{b_ct});
                            if (bridge1)
                            {
                                ParentSpec *parents[2] = { vinylOnBridge1, bridge1 };
                                create<VinylOnDimer>(parents);
                            }
                        }
                    }
                });
            }
        }
    }
    if (anchor->is(#{role_cl}))
    {
        if (!anchor->hasRole(VINYL_ON_DIMER, #{role_cl}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            if (bridge1)
            {
                eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_cr}))
                    {
                        if (anchor->hasBondWith(neighbour1))
                        {
                            VinylOnBridge *vinylOnBridge1 = neighbour1->specByRole<VinylOnBridge>(#{mob_cb});
                            if (vinylOnBridge1)
                            {
                                ParentSpec *parents[2] = { vinylOnBridge1, bridge1 };
                                create<VinylOnDimer>(parents);
                            }
                        }
                    }
                });
            }
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_vinyl_on_dimer_base }
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_vinyl_on_bridge_base,
                  subject
                ]
              end
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(VINYL_ON_DIMER, #{role_cr}))
        {
            anchor->eachAmorphNeighbour([&](Atom *amorph1) {
                if (amorph1->is(#{vob}))
                {
                    VinylOnBridge *vinylOnBridge1 = amorph1->specByRole<VinylOnBridge>(#{vob});
                    if (vinylOnBridge1)
                    {
                        eachNeighbour(anchor, &Diamond::front_100, [&anchor, &vinylOnBridge1](Atom *neighbour1) {
                            if (neighbour1->is(#{role_cl}))
                            {
                                if (anchor->hasBondWith(neighbour1))
                                {
                                    Bridge *bridge1 = neighbour1->specByRole<Bridge>(#{b_ct});
                                    if (bridge1)
                                    {
                                        ParentSpec *parents[2] = { vinylOnBridge1, bridge1 };
                                        create<VinylOnDimer>(parents);
                                    }
                                }
                            }
                        });
                    }
                }
            });
        }
    }
    if (anchor->is(#{role_cl}))
    {
        if (!anchor->hasRole(VINYL_ON_DIMER, #{role_cl}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            if (bridge1)
            {
                eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_cr}))
                    {
                        if (anchor->hasBondWith(neighbour1))
                        {
                            neighbour1->eachAmorphNeighbour([&bridge1](Atom *amorph1) {
                                if (amorph1->is(#{vob}))
                                {
                                    VinylOnBridge *vinylOnBridge1 = amorph1->specByRole<VinylOnBridge>(#{vob});
                                    if (vinylOnBridge1)
                                    {
                                        ParentSpec *parents[2] = { vinylOnBridge1, bridge1 };
                                        create<VinylOnDimer>(parents);
                                    }
                                }
                            });
                        }
                    }
                });
            }
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
                    atoms1[1]->eachAmorphNeighbour([&amorph1, &parent](Atom *amorph2) {
                        if (amorph2->is(#{role_c2}))
                        {
                            Atom *additionalAtoms[2] = { amorph2, amorph1 };
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
              subject { dept_two_methyls_on_dimer_base }
              let(:base_specs) do
                [dept_bridge_base, dept_dimer_base, dept_methyl_on_dimer_base, subject]
              end
              let(:typical_reactions) do
                [
                  dept_hydrogen_abs_from_gap,
                  dept_incoherent_dimer_drop,
                  dept_intermed_migr_dh_drop
                ]
              end
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = parent->atom(1);
    if (atom1->is(#{role_cr}))
    {
        if (!atom1->hasRole(TWO_METHYLS_ON_DIMER, #{role_cr}))
        {
            atom1->eachAmorphNeighbour([&parent](Atom *amorph1) {
                if (amorph1->is(#{role_c1}))
                {
                    create<TwoMethylsOnDimer>(amorph1, parent);
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
            if (bridge1)
            {
                anchor->eachAmorphNeighbour([&](Atom *amorph1) {
                    if (amorph1->is(#{role_cm}))
                    {
                        eachNeighbour(anchor, &Diamond::cross_100, [&amorph1, &bridge1](Atom *neighbour1) {
                            if (neighbour1->is(#{role_ctr}))
                            {
                                Bridge *bridge2 = neighbour1->specByRole<Bridge>(#{b_ct});
                                if (bridge2)
                                {
                                    if (neighbour1->hasBondWith(amorph1))
                                    {
                                        ParentSpec *parents[2] = { bridge1, bridge2 };
                                        create<CrossBridgeOnBridges>(amorph1, parents);
                                    }
                                }
                            }
                        });
                    }
                });
            }
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
            anchor->eachSpecsPortionByRole<MethylOnBridge>(#{mob_cm}, 2, [](MethylOnBridge **species1) {
                Atom *atoms1[2] = { species1[0]->atom(1), species1[1]->atom(1) };
                eachNeighbour(atoms1[0], &Diamond::cross_100, [&atoms1, &species1](Atom *neighbour1) {
                    if (neighbour1 == atoms1[1])
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
              let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_ctl}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_DIMERS, #{role_ctl}))
        {
            Dimer *dimer1 = anchor->specByRole<Dimer>(#{d_cr});
            if (dimer1)
            {
                Atom *atom1 = dimer1->atom(0);
                anchor->eachAmorphNeighbour([&](Atom *amorph1) {
                    if (amorph1->is(#{role_cm}))
                    {
                        Atom *atoms1[2] = { anchor, atom1 };
                        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&amorph1, &dimer1](Atom **neighbours1) {
                            if (neighbours1[0]->is(#{role_ctr}) && neighbours1[1]->is(#{role_csr}))
                            {
                                if (neighbours1[0]->hasBondWith(neighbours1[1]))
                                {
                                    Dimer *dimer2 = neighbours1[1]->specByRole<Dimer>(#{d_cr});
                                    if (dimer2)
                                    {
                                        if (neighbours1[0]->hasBondWith(amorph1))
                                        {
                                            ParentSpec *parents[2] = { dimer1, dimer2 };
                                            create<CrossBridgeOnDimers>(amorph1, parents);
                                        }
                                    }
                                }
                            }
                        });
                    }
                });
            }
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
            anchor->eachSpecsPortionByRole<MethylOnDimer>(#{mod_cm}, 2, [](MethylOnDimer **species1) {
                Atom *atoms1[4] = { species1[0]->atom(4), species1[0]->atom(1), species1[1]->atom(4), species1[1]->atom(1) };
                Atom *atoms2[2] = { atoms1[0], atoms1[1] };
                Atom *atoms3[2] = { atoms1[2], atoms1[3] };
                eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms3, &species1](Atom **neighbours1) {
                    if (neighbours1[0] == atoms3[0] && neighbours1[1] == atoms3[1])
                    {
                        ParentSpec *parents[2] = { species1[0], species1[1] };
                        create<CrossBridgeOnDimers>(parents);
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
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  subject
                ]
              end
              let(:typical_reactions) { [dept_cbod_drop] }

              let(:mod_cm) { role(dept_methyl_on_dimer_base, :cm) }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_DIMERS, #{role_cm}))
        {
            anchor->eachSpecsPortionByRole<MethylOnDimer>(#{mod_cm}, 2, [](MethylOnDimer **species1) {
                Atom *atoms1[4] = { species1[0]->atom(1), species1[0]->atom(4), species1[1]->atom(1), species1[1]->atom(4) };
                Atom *atoms2[2] = { atoms1[0], atoms1[1] };
                Atom *atoms3[2] = { atoms1[2], atoms1[3] };
                eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms3, &species1](Atom **neighbours1) {
                    if (neighbours1[0] == atoms3[0] && neighbours1[1] == atoms3[1])
                    {
                        ParentSpec *parents[2] = { species1[0], species1[1] };
                        create<CrossBridgeOnDimers>(parents);
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
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_cross_bridge_on_bridges_base,
                  subject
                ]
              end
              let(:typical_reactions) { [dept_cbod_drop] }

              let(:cbob_ctr) { role(dept_cross_bridge_on_bridges_base, :ctr) }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_csr}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_DIMERS, #{role_csr}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            if (bridge1)
            {
                eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_csr}))
                    {
                        Bridge *bridge2 = neighbour1->specByRole<Bridge>(#{b_ct});
                        if (bridge2)
                        {
                            Atom *atoms1[2] = { anchor, neighbour1 };
                            eachNeighbours<2>(atoms1, &Diamond::front_100, [&atoms1, &bridge1, &bridge2](Atom **neighbours1) {
                                if (neighbours1[0]->is(#{role_ctr}) && neighbours1[1]->is(#{role_ctr}))
                                {
                                    if (atoms1[0]->hasBondWith(neighbours1[0]) && atoms1[1]->hasBondWith(neighbours1[1]))
                                    {
                                        CrossBridgeOnBridges *crossBridgeOnBridges1 = neighbours1[1]->specByRole<CrossBridgeOnBridges>(#{cbob_ctr});
                                        if (crossBridgeOnBridges1)
                                        {
                                            crossBridgeOnBridges1->eachSymmetry([&bridge1, &bridge2, &neighbours1](ParentSpec *symmetricCrossBridgeOnBridges1) {
                                                if (neighbours1[0] == symmetricCrossBridgeOnBridges1->atom(5) && neighbours1[1] == symmetricCrossBridgeOnBridges1->atom(1))
                                                {
                                                    ParentSpec *parents[3] = { symmetricCrossBridgeOnBridges1, bridge1, bridge2 };
                                                    create<CrossBridgeOnDimers>(parents);
                                                }
                                            });
                                        }
                                    }
                                }
                            });
                        }
                    }
                });
            }
        }
    }
                CODE
              end
            end

            describe 'different three bridges' do
              subject { dept_three_bridges_base }
              let(:base_specs) { [dept_bridge_base, subject] }

              it_behaves_like :check_code do
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cc}))
    {
        if (!anchor->hasRole(THREE_BRIDGES, #{role_cc}))
        {
            anchor->eachSpecsPortionByRole<Bridge>(#{b_cr}, 2, [](Bridge **species1) {
                for (uint s = 0; s < 2; ++s)
                {
                    Atom *atom1 = species1[s]->atom(2);
                    Bridge *bridge1 = atom1->specByRole<Bridge>(#{b_ct});
                    if (bridge1)
                    {
                        ParentSpec *parents[3] = { species1[s], species1[1 - s], bridge1 };
                        create<ThreeBridges>(parents);
                    }
                }
            });
        }
    }
                  CODE
                end
              end

              it_behaves_like :check_code do
                let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cc}))
    {
        if (!anchor->hasRole(THREE_BRIDGES, #{role_cc}))
        {
            anchor->eachSpecsPortionByRole<Bridge>(#{b_cr}, 2, [&](Bridge **species1) {
                for (uint s = 0; s < 2; ++s)
                {
                    species1[s]->eachSymmetry([&](ParentSpec *symmetricBridge1) {
                        if (anchor == symmetricBridge1->atom(1))
                        {
                            species1[1 - s]->eachSymmetry([&anchor, &symmetricBridge1](ParentSpec *symmetricBridge2) {
                                if (anchor == symmetricBridge2->atom(1))
                                {
                                    Atom *atom1 = symmetricBridge1->atom(2);
                                    Bridge *bridge1 = atom1->specByRole<Bridge>(#{b_ct});
                                    if (bridge1)
                                    {
                                        ParentSpec *parents[3] = { symmetricBridge1, symmetricBridge2, bridge1 };
                                        create<ThreeBridges>(parents);
                                    }
                                }
                            });
                        }
                    });
                }
            });
        }
    }
                  CODE
                end
              end
            end

            describe 'different bridge with dimer' do
              subject { dept_bridge_with_dimer_base }
              let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }

              it_behaves_like :check_code do
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(BRIDGE_WITH_DIMER, #{role_cr}))
        {
            ParentSpec *species1[2] = { anchor->specByRole<Dimer>(#{d_cr}), anchor->specByRole<Bridge>(#{b_cr}) };
            if (species1[0] && species1[1])
            {
                Atom *atom1 = species1[1]->atom(2);
                Bridge *bridge1 = atom1->specByRole<Bridge>(#{b_ct});
                if (bridge1)
                {
                    ParentSpec *parents[3] = { species1[0], species1[1], bridge1 };
                    create<BridgeWithDimer>(parents);
                }
            }
        }
    }
                  CODE
                end
              end

              it_behaves_like :check_code do
                let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(BRIDGE_WITH_DIMER, #{role_cr}))
        {
            ParentSpec *species1[2] = { anchor->specByRole<Dimer>(#{d_cr}), anchor->specByRole<Bridge>(#{b_cr}) };
            if (species1[0] && species1[1])
            {
                species1[1]->eachSymmetry([&](ParentSpec *symmetricBridge1) {
                    if (anchor == symmetricBridge1->atom(1))
                    {
                        Atom *atom1 = symmetricBridge1->atom(2);
                        Bridge *bridge1 = atom1->specByRole<Bridge>(#{b_ct});
                        if (bridge1)
                        {
                            ParentSpec *parents[3] = { species1[0], symmetricBridge1, bridge1 };
                            create<BridgeWithDimer>(parents);
                        }
                    }
                });
            }
        }
    }
                  CODE
                end
              end

              it_behaves_like :check_code do
                let(:typical_reactions) { [dept_dimer_drop] }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(BRIDGE_WITH_DIMER, #{role_cr}))
        {
            ParentSpec *species1[2] = { anchor->specByRole<Dimer>(#{d_cr}), anchor->specByRole<Bridge>(#{b_cr}) };
            if (species1[0] && species1[1])
            {
                species1[0]->eachSymmetry([&](ParentSpec *symmetricDimer1) {
                    if (anchor == symmetricDimer1->atom(3))
                    {
                        Atom *atom1 = species1[1]->atom(2);
                        Bridge *bridge1 = atom1->specByRole<Bridge>(#{b_ct});
                        if (bridge1)
                        {
                            ParentSpec *parents[3] = { symmetricDimer1, species1[1], bridge1 };
                            create<BridgeWithDimer>(parents);
                        }
                    }
                });
            }
        }
    }
                  CODE
                end
              end

              it_behaves_like :check_code do
                let(:typical_reactions) { [dept_hydrogen_abs_from_gap, dept_dimer_drop] }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(BRIDGE_WITH_DIMER, #{role_cr}))
        {
            ParentSpec *species1[2] = { anchor->specByRole<Dimer>(#{d_cr}), anchor->specByRole<Bridge>(#{b_cr}) };
            if (species1[0] && species1[1])
            {
                species1[0]->eachSymmetry([&](ParentSpec *symmetricDimer1) {
                    if (anchor == symmetricDimer1->atom(3))
                    {
                        species1[1]->eachSymmetry([&anchor, &symmetricDimer1](ParentSpec *symmetricBridge1) {
                            if (anchor == symmetricBridge1->atom(1))
                            {
                                Atom *atom1 = symmetricBridge1->atom(2);
                                Bridge *bridge1 = atom1->specByRole<Bridge>(#{b_ct});
                                if (bridge1)
                                {
                                    ParentSpec *parents[3] = { symmetricDimer1, symmetricBridge1, bridge1 };
                                    create<BridgeWithDimer>(parents);
                                }
                            }
                        });
                    }
                });
            }
        }
    }
                  CODE
                end
              end
            end

            it_behaves_like :check_code do
              subject { dept_top_methyl_on_half_extended_bridge_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:typical_reactions) { [dept_migration_over_111] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_ct}))
    {
        if (!anchor->checkAndFind(TOP_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_ct}))
        {
            MethylOnBridge *methylOnBridge1 = anchor->specByRole<MethylOnBridge>(#{role_ct});
            if (methylOnBridge1)
            {
                methylOnBridge1->eachSymmetry([](ParentSpec *symmetricMethylOnBridge1) {
                    Atom *atom1 = symmetricMethylOnBridge1->atom(2);
                    Bridge *bridge1 = atom1->specByRole<Bridge>(#{b_ct});
                    if (bridge1)
                    {
                        ParentSpec *parents[2] = { symmetricMethylOnBridge1, bridge1 };
                        create<TopMethylOnHalfExtendedBridge>(parents);
                    }
                });
            }
        }
    }
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->checkAndFind(TOP_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            Bridge *bridge1 = anchor->specByRole<Bridge>(#{b_ct});
            if (bridge1)
            {
                eachNeighbour(anchor, &Diamond::front_110, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_ct}))
                    {
                        if (anchor->hasBondWith(neighbour1))
                        {
                            MethylOnBridge *methylOnBridge1 = neighbour1->specByRole<MethylOnBridge>(#{role_ct});
                            if (methylOnBridge1)
                            {
                                methylOnBridge1->eachSymmetry([&anchor, &bridge1](ParentSpec *symmetricMethylOnBridge1) {
                                    if (anchor == symmetricMethylOnBridge1->atom(2))
                                    {
                                        ParentSpec *parents[2] = { symmetricMethylOnBridge1, bridge1 };
                                        create<TopMethylOnHalfExtendedBridge>(parents);
                                    }
                                });
                            }
                        }
                    }
                });
            }
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_lower_methyl_on_half_extended_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:typical_reactions) { [dept_reverse_migration_over_111] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cbr}))
    {
        if (!anchor->checkAndFind(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cbr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *bridge1) {
                bridge1->eachSymmetry([&anchor](ParentSpec *symmetricBridge1) {
                    if (anchor == symmetricBridge1->atom(1))
                    {
                        Atom *atom1 = symmetricBridge1->atom(0);
                        if (atom1->is(#{role_cr}))
                        {
                            anchor->eachAmorphNeighbour([&atom1, &symmetricBridge1](Atom *amorph1) {
                                if (amorph1->is(#{role_cm}))
                                {
                                    atom1->eachSpecByRole<Bridge>(#{role_cr}, [&amorph1, &atom1, &symmetricBridge1](Bridge *bridge2) {
                                        bridge2->eachSymmetry([&amorph1, &atom1, &symmetricBridge1](ParentSpec *symmetricBridge2) {
                                            if (atom1 == symmetricBridge2->atom(2))
                                            {
                                                ParentSpec *parents[2] = { symmetricBridge1, symmetricBridge2 };
                                                create<LowerMethylOnHalfExtendedBridge>(amorph1, parents);
                                            }
                                        });
                                    });
                                }
                            });
                        }
                    }
                });
            });
        }
    }
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->checkAndFind(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *bridge1) {
                bridge1->eachSymmetry([&anchor](ParentSpec *symmetricBridge1) {
                    if (anchor == symmetricBridge1->atom(2))
                    {
                        Bridge *bridge2 = anchor->specByRole<Bridge>(#{b_ct});
                        if (bridge2)
                        {
                            bridge2->eachSymmetry([&symmetricBridge1](ParentSpec *symmetricBridge2) {
                                Atom *atom1 = symmetricBridge2->atom(1);
                                if (atom1->is(#{role_cbr}))
                                {
                                    atom1->eachAmorphNeighbour([&symmetricBridge1, &symmetricBridge2](Atom *amorph1) {
                                        if (amorph1->is(#{role_cm}))
                                        {
                                            ParentSpec *parents[2] = { symmetricBridge2, symmetricBridge1 };
                                            create<LowerMethylOnHalfExtendedBridge>(amorph1, parents);
                                        }
                                    });
                                }
                            });
                        }
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
              let(:typical_reactions) { [dept_reverse_migration_over_111] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cbr}))
    {
        if (!anchor->checkAndFind(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cbr}))
        {
            MethylOnRightBridge *methylOnRightBridge1 = anchor->specByRole<MethylOnRightBridge>(#{role_cbr});
            if (methylOnRightBridge1)
            {
                Atom *atom1 = methylOnRightBridge1->atom(1);
                if (atom1->is(#{role_cr}))
                {
                    atom1->eachSpecByRole<Bridge>(#{role_cr}, [&atom1, &methylOnRightBridge1](Bridge *bridge1) {
                        bridge1->eachSymmetry([&atom1, &methylOnRightBridge1](ParentSpec *symmetricBridge1) {
                            if (atom1 == symmetricBridge1->atom(2))
                            {
                                ParentSpec *parents[2] = { methylOnRightBridge1, symmetricBridge1 };
                                create<LowerMethylOnHalfExtendedBridge>(parents);
                            }
                        });
                    });
                }
            }
        }
    }
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->checkAndFind(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *bridge1) {
                bridge1->eachSymmetry([&anchor](ParentSpec *symmetricBridge1) {
                    if (anchor == symmetricBridge1->atom(2))
                    {
                        eachNeighbour(anchor, &Diamond::cross_110, [&anchor, &symmetricBridge1](Atom *neighbour1) {
                            if (neighbour1->is(#{role_cbr}))
                            {
                                if (anchor->hasBondWith(neighbour1))
                                {
                                    MethylOnRightBridge *methylOnRightBridge1 = neighbour1->specByRole<MethylOnRightBridge>(#{role_cbr});
                                    if (methylOnRightBridge1)
                                    {
                                        ParentSpec *parents[2] = { methylOnRightBridge1, symmetricBridge1 };
                                        create<LowerMethylOnHalfExtendedBridge>(parents);
                                    }
                                }
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
              let(:typical_reactions) { [dept_intermed_migr_db_drop] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_BRIDGE, #{role_cm}))
        {
            anchor->eachSpecsPortionByRole<MethylOnBridge>(#{mob_cm}, 2, [](MethylOnBridge **species1) {
                for (uint s = 0; s < 2; ++s)
                {
                    species1[s]->eachSymmetry([&s, &species1](ParentSpec *symmetricMethylOnBridge1) {
                        Atom *atoms1[2] = { symmetricMethylOnBridge1->atom(3), species1[1 - s]->atom(1) };
                        eachNeighbour(atoms1[0], &Diamond::cross_100, [&atoms1, &s, &species1, &symmetricMethylOnBridge1](Atom *neighbour1) {
                            if (neighbour1 == atoms1[1])
                            {
                                ParentSpec *parents[2] = { species1[1 - s], symmetricMethylOnBridge1 };
                                create<IntermedMigrDownBridge>(parents);
                            }
                        });
                    });
                }
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
                  dept_dimer_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  subject
                ]
              end

              describe 'without main reactions' do
                let(:typical_reactions) { [dept_migration_over_111] }
                it_behaves_like :check_code do
                  subject { dept_intermed_migr_down_common_base }
                  let(:find_algorithm) do
                    <<-CODE
    if (anchor->is(#{role_cdr}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_COMMON, #{role_cdr}))
        {
            MethylOnDimer *methylOnDimer1 = anchor->specByRole<MethylOnDimer>(#{role_cdr});
            if (methylOnDimer1)
            {
                Atom *amorph1 = methylOnDimer1->atom(0);
                if (amorph1->is(#{role_cm}))
                {
                    amorph1->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&anchor, &methylOnDimer1](MethylOnBridge *methylOnBridge1) {
                        if (anchor != methylOnBridge1->atom(1))
                        {
                            methylOnBridge1->eachSymmetry([&anchor, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                                Atom *atom1 = symmetricMethylOnBridge1->atom(2);
                                eachNeighbour(atom1, &Diamond::cross_100, [&anchor, &methylOnDimer1, &symmetricMethylOnBridge1](Atom *neighbour1) {
                                    if (neighbour1 == anchor)
                                    {
                                        ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                        create<IntermedMigrDownCommon>(parents);
                                    }
                                });
                            });
                        }
                    });
                }
            }
        }
    }
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_COMMON, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *methylOnBridge1) {
                methylOnBridge1->eachSymmetry([&anchor](ParentSpec *symmetricMethylOnBridge1) {
                    Atom *atom1 = symmetricMethylOnBridge1->atom(2);
                    eachNeighbour(atom1, &Diamond::cross_100, [&anchor, &symmetricMethylOnBridge1](Atom *neighbour1) {
                        if (neighbour1->is(#{role_cdr}))
                        {
                            MethylOnDimer *methylOnDimer1 = neighbour1->specByRole<MethylOnDimer>(#{role_cdr});
                            if (methylOnDimer1)
                            {
                                if (anchor == methylOnDimer1->atom(0))
                                {
                                    ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                    create<IntermedMigrDownCommon>(parents);
                                }
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
            MethylOnDimer *methylOnDimer1 = anchor->specByRole<MethylOnDimer>(#{role_cdr});
            if (methylOnDimer1)
            {
                Atom *atoms1[2] = { methylOnDimer1->atom(0), methylOnDimer1->atom(4) };
                if (atoms1[0]->is(#{role_cm}))
                {
                    atoms1[0]->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *methylOnBridge1) {
                        if (anchor != methylOnBridge1->atom(1))
                        {
                            methylOnBridge1->eachSymmetry([&anchor, &atoms1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                                Atom *atoms2[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                                Atom *atoms3[2] = { atoms1[1], anchor };
                                eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms3, &methylOnDimer1, &symmetricMethylOnBridge1](Atom **neighbours1) {
                                    if (neighbours1[0] != atoms3[0])
                                    {
                                        if (neighbours1[1] == atoms3[1])
                                        {
                                            ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                            create<IntermedMigrDownHalf>(parents);
                                        }
                                    }
                                });
                            });
                        }
                    });
                }
            }
        }
    }
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_HALF, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *methylOnBridge1) {
                methylOnBridge1->eachSymmetry([&anchor](ParentSpec *symmetricMethylOnBridge1) {
                    Atom *atoms1[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&anchor, &symmetricMethylOnBridge1](Atom **neighbours1) {
                        if (neighbours1[1]->is(#{role_cdr}))
                        {
                            MethylOnDimer *methylOnDimer1 = neighbours1[1]->specByRole<MethylOnDimer>(#{role_cdr});
                            if (methylOnDimer1)
                            {
                                if (neighbours1[0] != methylOnDimer1->atom(4))
                                {
                                    if (anchor == methylOnDimer1->atom(0))
                                    {
                                        ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                        create<IntermedMigrDownHalf>(parents);
                                    }
                                }
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
            MethylOnDimer *methylOnDimer1 = anchor->specByRole<MethylOnDimer>(#{role_cdr});
            if (methylOnDimer1)
            {
                Atom *atoms1[2] = { methylOnDimer1->atom(0), methylOnDimer1->atom(4) };
                if (atoms1[0]->is(#{role_cm}))
                {
                    atoms1[0]->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *methylOnBridge1) {
                        if (anchor != methylOnBridge1->atom(1))
                        {
                            methylOnBridge1->eachSymmetry([&anchor, &atoms1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                                Atom *atoms2[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                                Atom *atoms3[2] = { atoms1[1], anchor };
                                eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms3, &methylOnDimer1, &symmetricMethylOnBridge1](Atom **neighbours1) {
                                    if (neighbours1[0] == atoms3[0] && neighbours1[1] == atoms3[1])
                                    {
                                        ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                        create<IntermedMigrDownFull>(parents);
                                    }
                                });
                            });
                        }
                    });
                }
            }
        }
    }
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_FULL, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *methylOnBridge1) {
                methylOnBridge1->eachSymmetry([&anchor](ParentSpec *symmetricMethylOnBridge1) {
                    Atom *atoms1[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&anchor, &symmetricMethylOnBridge1](Atom **neighbours1) {
                        if (neighbours1[0]->is(#{role_cdl}) && neighbours1[1]->is(#{role_cdr}))
                        {
                            if (neighbours1[0]->hasBondWith(neighbours1[1]))
                            {
                                MethylOnDimer *methylOnDimer1 = neighbours1[1]->specByRole<MethylOnDimer>(#{role_cdr});
                                if (methylOnDimer1)
                                {
                                    if (neighbours1[0] == methylOnDimer1->atom(4))
                                    {
                                        if (anchor == methylOnDimer1->atom(0))
                                        {
                                            ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                            create<IntermedMigrDownFull>(parents);
                                        }
                                    }
                                }
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

              describe 'with main reactions' do
                it_behaves_like :check_code do
                  subject { dept_intermed_migr_down_common_base }
                  let(:typical_reactions) { [dept_intermed_migr_dc_drop] }
                  let(:find_algorithm) do
                    <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_COMMON, #{role_cm}))
        {
            MethylOnDimer *methylOnDimer1 = anchor->specByRole<MethylOnDimer>(#{mob_cm});
            if (methylOnDimer1)
            {
                Atom *atom1 = methylOnDimer1->atom(1);
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&atom1, &methylOnDimer1](MethylOnBridge *methylOnBridge1) {
                    if (atom1 != methylOnBridge1->atom(1))
                    {
                        methylOnBridge1->eachSymmetry([&atom1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                            Atom *atom2 = symmetricMethylOnBridge1->atom(2);
                            eachNeighbour(atom2, &Diamond::cross_100, [&atom1, &methylOnDimer1, &symmetricMethylOnBridge1](Atom *neighbour1) {
                                if (neighbour1 == atom1)
                                {
                                    ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                    create<IntermedMigrDownCommon>(parents);
                                }
                            });
                        });
                    }
                });
            }
        }
    }
                    CODE
                  end
                end

                it_behaves_like :check_code do
                  subject { dept_intermed_migr_down_half_base }
                  let(:typical_reactions) { [dept_intermed_migr_dh_drop] }
                  let(:find_algorithm) do
                    <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_HALF, #{role_cm}))
        {
            MethylOnDimer *methylOnDimer1 = anchor->specByRole<MethylOnDimer>(#{mob_cm});
            if (methylOnDimer1)
            {
                Atom *atoms1[2] = { methylOnDimer1->atom(4), methylOnDimer1->atom(1) };
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&atoms1, &methylOnDimer1](MethylOnBridge *methylOnBridge1) {
                    if (atoms1[1] != methylOnBridge1->atom(1))
                    {
                        methylOnBridge1->eachSymmetry([&atoms1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                            Atom *atoms2[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                            eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms1, &methylOnDimer1, &symmetricMethylOnBridge1](Atom **neighbours1) {
                                if (neighbours1[0] != atoms1[0])
                                {
                                    if (neighbours1[1] == atoms1[1])
                                    {
                                        ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                        create<IntermedMigrDownHalf>(parents);
                                    }
                                }
                            });
                        });
                    }
                });
            }
        }
    }
                    CODE
                  end
                end

                it_behaves_like :check_code do
                  subject { dept_intermed_migr_down_full_base }
                  let(:typical_reactions) { [dept_intermed_migr_df_drop] }
                  let(:find_algorithm) do
                    <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_FULL, #{role_cm}))
        {
            MethylOnDimer *methylOnDimer1 = anchor->specByRole<MethylOnDimer>(#{mob_cm});
            if (methylOnDimer1)
            {
                Atom *atoms1[2] = { methylOnDimer1->atom(4), methylOnDimer1->atom(1) };
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&atoms1, &methylOnDimer1](MethylOnBridge *methylOnBridge1) {
                    if (atoms1[1] != methylOnBridge1->atom(1))
                    {
                        methylOnBridge1->eachSymmetry([&atoms1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                            Atom *atoms2[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                            eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms1, &methylOnDimer1, &symmetricMethylOnBridge1](Atom **neighbours1) {
                                if (neighbours1[0] == atoms1[0] && neighbours1[1] == atoms1[1])
                                {
                                    ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                    create<IntermedMigrDownFull>(parents);
                                }
                            });
                        });
                    }
                });
            }
        }
    }
                    CODE
                  end
                end
              end

              describe 'with main reactions and cross bridge on dimers' do
                let(:base_specs) do
                  [
                    dept_bridge_base,
                    dept_dimer_base,
                    dept_methyl_on_bridge_base,
                    dept_methyl_on_dimer_base,
                    dept_cross_bridge_on_dimers_base,
                    subject
                  ]
                end
                it_behaves_like :check_code do
                  subject { dept_intermed_migr_down_common_base }
                  let(:typical_reactions) { [dept_intermed_migr_dc_drop] }
                  let(:find_algorithm) do
                    <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_COMMON, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnDimer>(#{mob_cm}, [&](MethylOnDimer *methylOnDimer1) {
                Atom *atom1 = methylOnDimer1->atom(1);
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&atom1, &methylOnDimer1](MethylOnBridge *methylOnBridge1) {
                    if (atom1 != methylOnBridge1->atom(1))
                    {
                        methylOnBridge1->eachSymmetry([&atom1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                            Atom *atom2 = symmetricMethylOnBridge1->atom(2);
                            eachNeighbour(atom2, &Diamond::cross_100, [&atom1, &methylOnDimer1, &symmetricMethylOnBridge1](Atom *neighbour1) {
                                if (neighbour1 == atom1)
                                {
                                    ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                    create<IntermedMigrDownCommon>(parents);
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
                  subject { dept_intermed_migr_down_half_base }
                  let(:typical_reactions) { [dept_intermed_migr_dh_drop] }
                  let(:find_algorithm) do
                    <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_HALF, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnDimer>(#{mob_cm}, [&](MethylOnDimer *methylOnDimer1) {
                Atom *atoms1[2] = { methylOnDimer1->atom(4), methylOnDimer1->atom(1) };
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&atoms1, &methylOnDimer1](MethylOnBridge *methylOnBridge1) {
                    if (atoms1[1] != methylOnBridge1->atom(1))
                    {
                        methylOnBridge1->eachSymmetry([&atoms1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                            Atom *atoms2[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                            eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms1, &methylOnDimer1, &symmetricMethylOnBridge1](Atom **neighbours1) {
                                if (neighbours1[0] != atoms1[0])
                                {
                                    if (neighbours1[1] == atoms1[1])
                                    {
                                        ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                        create<IntermedMigrDownHalf>(parents);
                                    }
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
                  subject { dept_intermed_migr_down_full_base }
                  let(:typical_reactions) { [dept_intermed_migr_df_drop] }
                  let(:find_algorithm) do
                    <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_FULL, #{role_cm}))
        {
            anchor->eachSpecByRole<MethylOnDimer>(#{mob_cm}, [&](MethylOnDimer *methylOnDimer1) {
                Atom *atoms1[2] = { methylOnDimer1->atom(4), methylOnDimer1->atom(1) };
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&atoms1, &methylOnDimer1](MethylOnBridge *methylOnBridge1) {
                    if (atoms1[1] != methylOnBridge1->atom(1))
                    {
                        methylOnBridge1->eachSymmetry([&atoms1, &methylOnDimer1](ParentSpec *symmetricMethylOnBridge1) {
                            Atom *atoms2[2] = { symmetricMethylOnBridge1->atom(3), symmetricMethylOnBridge1->atom(2) };
                            eachNeighbours<2>(atoms2, &Diamond::cross_100, [&atoms1, &methylOnDimer1, &symmetricMethylOnBridge1](Atom **neighbours1) {
                                if (neighbours1[0] == atoms1[0] && neighbours1[1] == atoms1[1])
                                {
                                    ParentSpec *parents[2] = { methylOnDimer1, symmetricMethylOnBridge1 };
                                    create<IntermedMigrDownFull>(parents);
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
              end
            end
          end
        end

      end
    end
  end
end
