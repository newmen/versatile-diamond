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
            auto neighbours1 = crystalBy(anchor)->cross_110(anchor);
            if (neighbours1.all() && neighbours1[0]->is(#{role_cr}) && neighbours1[1]->is(#{role_cr}) && anchor->hasBondWith(neighbours1[0]) && anchor->hasBondWith(neighbours1[1]))
            {
                Atom *atoms[3] = { anchor, neighbours1[0], neighbours1[1] };
                create<Bridge>(atoms);
            }
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_right_hydrogenated_bridge }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [subject] }
              let(:find_algorithm) do
                <<-CODE
    parent->eachSymmetry([](ParentSpec *specie1) {
        Atom *anchor = specie1->atom(2);
        if (anchor->is(#{role_cr}))
        {
            if (!anchor->hasRole(BRIDGE_CRH, #{role_cr}))
            {
                create<BridgeCRH>(specie1);
            }
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:specific_specs) { [dept_activated_methyl_on_bridge] }
              let(:find_algorithm) do
                <<-CODE
    Atom *anchor = parent->atom(0);
    if (anchor->is(#{role_cb}))
    {
        if (!anchor->checkAndFind(METHYL_ON_BRIDGE, #{role_cb}))
        {
            Atom *amorph1 = anchor->amorphNeighbour();
            if (amorph1->is(#{role_cm}))
            {
                create<MethylOnBridge>(amorph1, parent);
            }
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
    Atom *anchors[2] = { parent->atom(1), parent->atom(0) };
    if (anchors[0]->is(#{role_cb}) && anchors[1]->is(#{role_cm}))
    {
        if (!anchors[0]->hasRole(METHYL_ON_BRIDGE_CBi_CMs, #{role_cb}) || !anchors[1]->hasRole(METHYL_ON_BRIDGE_CBi_CMs, #{role_cm}))
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
    Atom *anchor = parent->atom(0);
    if (anchor->is(#{role_cb}))
    {
        if (!anchor->hasRole(HIGH_BRIDGE, #{role_cb}))
        {
            Atom *amorph1 = anchor->amorphNeighbour();
            if (amorph1->is(#{role_cm}))
            {
                create<HighBridge>(amorph1, parent);
            }
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
    Atom *anchor = parent->atom(0);
    if (anchor->is(#{role_cb}))
    {
        if (!anchor->hasRole(VINYL_ON_BRIDGE, #{role_cb}))
        {
            Atom *amorph1 = anchor->amorphNeighbour();
            if (amorph1->is(#{role_c1}))
            {
                Atom *amorph2 = amorph1->amorphNeighbour();
                if (amorph2->is(#{role_c2}))
                {
                    Atom *additionalAtoms[2] = { amorph1, amorph2 };
                    create<VinylOnBridge>(additionalAtoms, parent);
                }
            }
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
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                if (neighbour1->is(#{role_cr}) && anchor->hasBondWith(neighbour1))
                {
                    ParentSpec *parents[2] = { anchor->specByRole<Bridge>(#{b_ct}), neighbour1->specByRole<Bridge>(#{b_ct}) };
                    create<Dimer>(parents);
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
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                if (neighbour1->is(#{role_cl}) && anchor->hasBondWith(neighbour1))
                {
                    ParentSpec *parents[2] = { anchor->specByRole<MethylOnBridge>(#{mob_cb}), neighbour1->specByRole<Bridge>(#{b_ct}) };
                    create<MethylOnDimer>(parents);
                }
            });
        }
    }
    else if (anchor->is(#{role_cl}))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER, #{role_cl}))
        {
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
                if (neighbour1->is(#{role_cr}) && anchor->hasBondWith(neighbour1))
                {
                    ParentSpec *parents[2] = { neighbour1->specByRole<MethylOnBridge>(#{mob_cb}), anchor->specByRole<Bridge>(#{b_ct}) };
                    create<MethylOnDimer>(parents);
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
    Atom *anchors[2] = { parent->atom(0), parent->atom(3) };
    if (anchors[0]->is(#{role_cr}) && anchors[1]->is(#{role_cl}))
    {
        if (!anchors[0]->hasRole(TWO_METHYLS_ON_DIMER, #{role_cr}) || !anchors[1]->hasRole(TWO_METHYLS_ON_DIMER, #{role_cl}))
        {
            Atom *amorph1 = anchors[0]->amorphNeighbour();
            if (amorph1->is(#{role_c1}))
            {
                Atom *amorph2 = anchors[1]->amorphNeighbour();
                if (amorph2->is(#{role_c2}))
                {
                    Atom *additionalAtoms[2] = { amorph1, amorph2 };
                    create<TwoMethylsOnDimer>(additionalAtoms, parent);
                }
            }
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
            Atom *amorph1 = anchor->amorphNeighbour();
            if (amorph1->is(#{role_cm}))
            {
                eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour1) {
                    if (neighbour1->is(#{role_ctr}))
                    {
                        if (neighbour1->hasBondWith(amorph1))
                        {
                            ParentSpec *parents[2] = { anchor->specByRole<Bridge>(#{b_ct}), neighbour1->specByRole<Bridge>(#{b_ct}) };
                            create<CrossBridgeOnBridges>(amorph1, parents);
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
            auto species1 = anchor->specsByRole<MethylOnBridge, 2>(#{mob_cm});
            if (species1.all())
            {
                Atom *atoms[2] = { species1[0]->atom(1), species1[1]->atom(1) };
                eachNeighbour(atoms[0], &Diamond::cross_100, [&](Atom *neighbour1) {
                    if (atoms[1] == neighbour1)
                    {
                        ParentSpec *parents[2] = { species1[0], species1[1] };
                        create<CrossBridgeOnBridges>(parents);
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
                [dept_bridge_base, dept_dimer_base, subject]
              end

              let(:mod_cm) { role(dept_methyl_on_dimer_base, :cm) }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_ctl}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_DIMERS, #{role_ctl}))
        {
            Atom *amorph1 = anchor->amorphNeighbour();
            if (amorph1->is(#{role_cm}))
            {
                Dimer *specie1 = anchor->specByRole<Dimer>(#{d_cr});
                Atom *anchors[2] = { specie1->atom(0), anchor };
                eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
                    if (neighbours1[0]->is(#{role_csr}) && neighbours1[1]->is(#{role_ctr}))
                    {
                        if (neighbours1[1]->hasBondWith(amorph1))
                        {
                            ParentSpec *parents[2] = { specie1, neighbours1[0]->specByRole<Dimer>(#{d_cr}) };
                            create<CrossBridgeOnDimers>(amorph1, parents);
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
            auto species1 = anchor->specsByRole<MethylOnDimer, 2>(#{mod_cm});
            if (species1.all())
            {
                Atom *atoms[4] = { species1[0]->atom(4), species1[0]->atom(1), species1[1]->atom(4), species1[1]->atom(1) };
                Atom *anchors[2] = { atoms[2], atoms[3] };
                eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
                    if (atoms[0] == neighbours1[0] && atoms[1] == neighbours1[1])
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
            anchor->eachSpecByRole<Bridge>(#{b_cr}, [&](Bridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (anchor == specie1->atom(1))
                    {
                        anchor->eachSpecByRole<Bridge>(#{b_cr}, [&](Bridge *target2) {
                            if (target2 != target1)
                            {
                                target2->eachSymmetry([&](ParentSpec *specie2) {
                                    if (anchor == specie2->atom(2))
                                    {
                                        Atom *atom1 = specie1->atom(2);
                                        ParentSpec *specie3 = atom1->specByRole<Bridge>(#{b_ct});
                                        ParentSpec *parents[3] = { specie1, specie2, specie3 };
                                        create<ThreeBridges>(parents);
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
                    if (anchor == specie1->atom(0))
                    {
                        anchor->eachSpecByRole<Bridge>(#{b_cr}, [&](Bridge *target2) {
                            target2->eachSymmetry([&](ParentSpec *specie2) {
                                if (anchor == specie2->atom(1))
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

              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(TOP_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            anchor->eachSpecByRole<MethylOnBridge>(#{role_cr}, [&](MethylOnBridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (anchor == specie1->atom(2))
                    {
                        ParentSpec *parents[2] = { specie1, anchor->specByRole<Bridge>(0) };
                        create<TopMethylOnHalfExtendedBridge>(parents);
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
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (anchor == specie1->atom(2))
                    {
                        Bridge *specie2 = anchor->specByRole<Bridge>(0);
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atom1 = specie3->atom(1);
                            if (atom1->is(#{role_cbr}))
                            {
                                Atom *amorph1 = atom1->amorphNeighbour();
                                if (amorph1->is(#{role_cm}))
                                {
                                    ParentSpec *parents[2] = { specie3, specie1 };
                                    create<LowerMethylOnHalfExtendedBridge>(amorph1, parents);
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
              subject { dept_lower_methyl_on_half_extended_bridge_base }
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_right_bridge_base, subject]
              end

              let(:find_algorithm) do
                <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(LOWER_METHYL_ON_HALF_EXTENDED_BRIDGE, #{role_cr}))
        {
            anchor->eachSpecByRole<Bridge>(#{role_cr}, [&](Bridge *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (anchor == specie1->atom(2))
                    {
                        ParentSpec *parents[2] = { anchor->specByRole<MethylOnRightBridge>(0), specie1 };
                        create<LowerMethylOnHalfExtendedBridge>(parents);
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
            anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie1) {
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie2) {
                    if (specie1 != specie2)
                    {
                        specie1->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atoms[2] = { specie3->atom(3), specie2->atom(1) };
                            eachNeighbour(atoms[0], &Diamond::cross_100, [&](Atom *neighbour1) {
                                if (atoms[1] == neighbour1)
                                {
                                    ParentSpec *parents[2] = { specie3, specie2 };
                                    create<IntermedMigrDownBridge>(parents);
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
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_COMMON, #{role_cm}))
        {
            MethylOnDimer *specie1 = anchor->specByRole<MethylOnDimer>(#{mod_cm});
            if (specie1)
            {
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie2) {
                    if (specie2->atom(1) != specie1->atom(1))
                    {
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atoms[2] = { specie1->atom(1), specie3->atom(2) };
                            eachNeighbour(atoms[0], &Diamond::cross_100, [&](Atom *neighbour1) {
                                if (atoms[1] == neighbour1)
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
                  CODE
                end
              end

              it_behaves_like :check_code do
                subject { dept_intermed_migr_down_half_base }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_HALF, #{role_cm}))
        {
            MethylOnDimer *specie1 = anchor->specByRole<MethylOnDimer>(#{mod_cm});
            if (specie1)
            {
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie2) {
                    if (specie2->atom(1) != specie1->atom(1))
                    {
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atoms[4] = { specie1->atom(1), specie1->atom(4), specie3->atom(2), specie3->atom(3) };
                            Atom *anchors[2] = { atoms[0], atoms[1] };
                            eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
                                if (atoms[2] == neighbours1[0] && atoms[3] != neighbours1[1])
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
                  CODE
                end
              end

              it_behaves_like :check_code do
                subject { dept_intermed_migr_down_full_base }
                let(:find_algorithm) do
                  <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(INTERMED_MIGR_DOWN_FULL, #{role_cm}))
        {
            MethylOnDimer *specie1 = anchor->specByRole<MethylOnDimer>(#{mod_cm});
            if (specie1)
            {
                anchor->eachSpecByRole<MethylOnBridge>(#{mob_cm}, [&](MethylOnBridge *specie2) {
                    if (specie2->atom(1) != specie1->atom(1))
                    {
                        specie2->eachSymmetry([&](ParentSpec *specie3) {
                            Atom *atoms[4] = { specie1->atom(1), specie1->atom(4), specie3->atom(2), specie3->atom(3) };
                            Atom *anchors[2] = { atoms[0], atoms[1] };
                            eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
                                if (atoms[2] == neighbours1[0] && atoms[3] == neighbours1[1])
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
