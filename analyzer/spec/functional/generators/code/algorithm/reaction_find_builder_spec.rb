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
              let(:target_spec) { dept_hydrogenated_methyl_on_bridge }
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
              subject { dept_vinyl_adsorption }
              let(:target_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    create<ForwardVinylAdsorption>(target);
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
                    if (methylOnBridgeCMs1)
                    {
                        SpecificSpec *targets[2] = { target, methylOnBridgeCMs1 };
                        create<ReverseSierpinskiDrop>(targets);
                    }
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
            if (bridgeCTs1)
            {
                SpecificSpec *targets[2] = { bridgeCTs1, target };
                create<ReverseSierpinskiDrop>(targets);
            }
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
              subject { dept_dimer_drop_near_bridge }
              let(:target_spec) { dept_bridge_with_dimer_base }
              let(:find_algorithm) do
                <<-CODE
    create<ReverseDimerFormationNearBridge>(target);
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
            if (bridgeCTs1)
            {
                SpecificSpec *targets[2] = { bridgeCTs1, target };
                create<ForwardDimerFormation>(targets);
            }
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
            if (bridgeCTsi1)
            {
                SpecificSpec *targets[2] = { target, bridgeCTsi1 };
                create<ForwardDimerFormation>(targets);
            }
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_formation_near_bridge }
              let(:target_spec) { dept_right_activated_bridge }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(2);
    eachNeighbour(atom1, &Diamond::front_100, [&target](Atom *neighbour1) {
        if (neighbour1 != target->atom(1))
        {
            if (neighbour1->is(#{other_role_ct}))
            {
                BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
                if (bridgeCTs1)
                {
                    SpecificSpec *targets[2] = { target, bridgeCTs1 };
                    create<ForwardDimerFormationNearBridge>(targets);
                }
            }
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_formation_near_bridge }
              let(:target_spec) { dept_activated_bridge }
              let(:other_spec) { dept_right_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(0);
    eachNeighbour(atom1, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cr}))
        {
            BridgeCRs *bridgeCRs1 = neighbour1->specByRole<BridgeCRs>(#{other_role_cr});
            if (bridgeCRs1)
            {
                if (atom1 != bridgeCRs1->atom(1))
                {
                    SpecificSpec *targets[2] = { bridgeCRs1, target };
                    create<ForwardDimerFormationNearBridge>(targets);
                }
            }
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
                        if (methylOnDimerCMs1)
                        {
                            SpecificSpec *targets[2] = { symmetricBridgeCTs1, methylOnDimerCMs1 };
                            create<ForwardIntermedMigrDcFormation>(targets);
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
              subject { dept_intermed_migr_dc_formation }
              let(:target_spec) { dept_activated_methyl_on_dimer }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target->atom(4);
    eachNeighbour(atom1, &Diamond::cross_100, [&target](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cr}))
        {
            eachNeighbour(neighbour1, &Diamond::front_110, [&neighbour1, &target](Atom *neighbour2) {
                if (neighbour2->is(#{other_role_ct}))
                {
                    if (neighbour1->hasBondWith(neighbour2))
                    {
                        BridgeCTs *bridgeCTs1 = neighbour2->specByRole<BridgeCTs>(#{other_role_ct});
                        if (bridgeCTs1)
                        {
                            bridgeCTs1->eachSymmetry([&neighbour1, &target](SpecificSpec *symmetricBridgeCTs1) {
                                if (neighbour1 == symmetricBridgeCTs1->atom(2))
                                {
                                    SpecificSpec *targets[2] = { symmetricBridgeCTs1, target };
                                    create<ForwardIntermedMigrDcFormation>(targets);
                                }
                            });
                        }
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
        Atom *atoms1[2] = { symmetricBridgeCTs1->atom(1), symmetricBridgeCTs1->atom(2) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricBridgeCTs1](Atom **neighbours1) {
            if (neighbours1[1]->is(#{other_role_cr}))
            {
                neighbours1[1]->eachAmorphNeighbour([&neighbours1, &symmetricBridgeCTs1](Atom *amorph1) {
                    if (amorph1->is(#{other_role_cm}))
                    {
                        MethylOnDimerCMs *methylOnDimerCMs1 = amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm});
                        if (methylOnDimerCMs1)
                        {
                            if (neighbours1[0] != methylOnDimerCMs1->atom(1))
                            {
                                SpecificSpec *targets[2] = { symmetricBridgeCTs1, methylOnDimerCMs1 };
                                create<ForwardIntermedMigrDhFormation>(targets);
                            }
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
    Atom *atoms1[2] = { target->atom(4), target->atom(1) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&target](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}))
        {
            eachNeighbour(neighbours1[0], &Diamond::front_110, [&neighbours1, &target](Atom *neighbour1) {
                if (neighbour1->is(#{other_role_ct}))
                {
                    if (neighbours1[0]->hasBondWith(neighbour1))
                    {
                        BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
                        if (bridgeCTs1)
                        {
                            bridgeCTs1->eachSymmetry([&neighbours1, &target](SpecificSpec *symmetricBridgeCTs1) {
                                if (neighbours1[1] != symmetricBridgeCTs1->atom(1))
                                {
                                    if (neighbours1[0] == symmetricBridgeCTs1->atom(2))
                                    {
                                        SpecificSpec *targets[2] = { symmetricBridgeCTs1, target };
                                        create<ForwardIntermedMigrDhFormation>(targets);
                                    }
                                }
                            });
                        }
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
        Atom *atoms1[2] = { symmetricBridgeCTs1->atom(1), symmetricBridgeCTs1->atom(2) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricBridgeCTs1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cl}) && neighbours1[1]->is(#{other_role_cr}))
            {
                if (neighbours1[0]->hasBondWith(neighbours1[1]))
                {
                    neighbours1[1]->eachAmorphNeighbour([&symmetricBridgeCTs1](Atom *amorph1) {
                        if (amorph1->is(#{other_role_cm}))
                        {
                            MethylOnDimerCMs *methylOnDimerCMs1 = amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm});
                            if (methylOnDimerCMs1)
                            {
                                SpecificSpec *targets[2] = { symmetricBridgeCTs1, methylOnDimerCMs1 };
                                create<ForwardIntermedMigrDfFormation>(targets);
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

            it_behaves_like :check_code do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              subject { dept_intermed_migr_df_formation }
              let(:target_spec) { dept_activated_methyl_on_dimer }
              let(:other_spec) { dept_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { target->atom(4), target->atom(1) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&target](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
        {
            neighbourFrom(neighbours1, &Diamond::front_110_at, [&neighbours1, &target](Atom *neighbour1) {
                if (neighbour1->is(#{other_role_ct}))
                {
                    if (neighbours1[0]->hasBondWith(neighbour1) && neighbours1[1]->hasBondWith(neighbour1))
                    {
                        BridgeCTs *bridgeCTs1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
                        if (bridgeCTs1)
                        {
                            bridgeCTs1->eachSymmetry([&neighbours1, &target](SpecificSpec *symmetricBridgeCTs1) {
                                if (neighbours1[0] == symmetricBridgeCTs1->atom(2) && neighbours1[1] == symmetricBridgeCTs1->atom(1))
                                {
                                    SpecificSpec *targets[2] = { symmetricBridgeCTs1, target };
                                    create<ForwardIntermedMigrDfFormation>(targets);
                                }
                            });
                        }
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
              subject { dept_methyl_incorporation }
              let(:target_spec) { dept_activated_methyl_on_bridge }
              let(:other_spec) { dept_activated_dimer }
              let(:find_algorithm) do
                <<-CODE
    target->eachSymmetry([](SpecificSpec *symmetricMethylOnBridgeCMs1) {
        Atom *atoms1[2] = { symmetricMethylOnBridgeCMs1->atom(2), symmetricMethylOnBridgeCMs1->atom(3) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricMethylOnBridgeCMs1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cl}))
            {
                if (neighbours1[0]->hasBondWith(neighbours1[1]))
                {
                    DimerCRs *dimerCRs1 = neighbours1[0]->specByRole<DimerCRs>(#{other_role_cr});
                    if (dimerCRs1)
                    {
                        SpecificSpec *targets[2] = { symmetricMethylOnBridgeCMs1, dimerCRs1 };
                        create<ForwardMethylIncorporation>(targets);
                    }
                }
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
    Atom *atoms1[2] = { target->atom(3), target->atom(0) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&target](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
        {
            neighbourFrom(neighbours1, &Diamond::front_110_at, [&neighbours1, &target](Atom *neighbour1) {
                if (neighbour1->is(#{other_role_cb}))
                {
                    if (neighbours1[0]->hasBondWith(neighbour1) && neighbours1[1]->hasBondWith(neighbour1))
                    {
                        neighbour1->eachAmorphNeighbour([&neighbours1, &target](Atom *amorph1) {
                            if (amorph1->is(#{other_role_cm}))
                            {
                                MethylOnBridgeCMs *methylOnBridgeCMs1 = amorph1->specByRole<MethylOnBridgeCMs>(#{other_role_cm});
                                if (methylOnBridgeCMs1)
                                {
                                    methylOnBridgeCMs1->eachSymmetry([&neighbours1, &target](SpecificSpec *symmetricMethylOnBridgeCMs1) {
                                        if (neighbours1[0] == symmetricMethylOnBridgeCMs1->atom(2) && neighbours1[1] == symmetricMethylOnBridgeCMs1->atom(3))
                                        {
                                            SpecificSpec *targets[2] = { symmetricMethylOnBridgeCMs1, target };
                                            create<ForwardMethylIncorporation>(targets);
                                        }
                                    });
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
              let(:base_specs) { [dept_bridge_base] }
              subject { dept_methyl_to_gap }
              let(:target_spec) { dept_extra_activated_methyl_on_bridge }
              let(:other_spec) { dept_right_activated_bridge }
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { target->atom(2), target->atom(3) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&target](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
        {
            BridgeCRs *bridgeCRs1 = neighbours1[1]->specByRole<BridgeCRs>(#{other_role_cr});
            if (bridgeCRs1)
            {
                if (neighbours1[0] != bridgeCRs1->atom(1))
                {
                    BridgeCRs *bridgeCRs2 = neighbours1[0]->specByRole<BridgeCRs>(#{other_role_cr});
                    if (bridgeCRs2)
                    {
                        if (neighbours1[1] != bridgeCRs2->atom(1))
                        {
                            SpecificSpec *targets[3] = { bridgeCRs1, bridgeCRs2, target };
                            create<ForwardMethylToGap>(targets);
                        }
                    }
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
    Atom *atom1 = target->atom(2);
    eachNeighbour(atom1, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1 != target->atom(1))
        {
            if (neighbour1->is(#{role_cr}))
            {
                BridgeCRs *bridgeCRs1 = neighbour1->specByRole<BridgeCRs>(#{role_cr});
                if (bridgeCRs1)
                {
                    if (atom1 != bridgeCRs1->atom(1))
                    {
                        Atom *atoms1[2] = { neighbour1, atom1 };
                        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&bridgeCRs1, &target](Atom **neighbours1) {
                            if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
                            {
                                neighbourFrom(neighbours1, &Diamond::front_110_at, [&bridgeCRs1, &neighbours1, &target](Atom *neighbour2) {
                                    if (neighbour2->is(#{other_role_cb}))
                                    {
                                        if (neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                                        {
                                            neighbour2->eachAmorphNeighbour([&bridgeCRs1, &target](Atom *amorph1) {
                                                if (amorph1->is(#{other_role_cm}))
                                                {
                                                    MethylOnBridgeCMss *methylOnBridgeCMss1 = amorph1->specByRole<MethylOnBridgeCMss>(#{other_role_cm});
                                                    if (methylOnBridgeCMss1)
                                                    {
                                                        SpecificSpec *targets[3] = { bridgeCRs1, target, methylOnBridgeCMss1 };
                                                        create<ForwardMethylToGap>(targets);
                                                    }
                                                }
                                            });
                                        }
                                    }
                                });
                            }
                        });
                    }
                }
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
    Atom *atom1 = target->atom(2);
    eachNeighbour(atom1, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cl}))
        {
            DimerCLsCRi *dimerCLsCRi1 = neighbour1->specByRole<DimerCLsCRi>(#{other_role_cl});
            if (dimerCLsCRi1)
            {
                Atom *atoms1[2] = { neighbour1, atom1 };
                eachNeighbours<2>(atoms1, &Diamond::cross_100, [&dimerCLsCRi1, &target](Atom **neighbours1) {
                    if (neighbours1[0]->is(#{thrid_role_cr}) && neighbours1[1]->is(#{thrid_role_cr}))
                    {
                        neighbourFrom(neighbours1, &Diamond::front_110_at, [&dimerCLsCRi1, &neighbours1, &target](Atom *neighbour2) {
                            if (neighbour2->is(#{thrid_role_cb}))
                            {
                                if (neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                                {
                                    neighbour2->eachAmorphNeighbour([&dimerCLsCRi1, &neighbours1, &target](Atom *amorph1) {
                                        if (amorph1->is(#{thrid_role_cm}))
                                        {
                                            MethylOnBridgeCMss *methylOnBridgeCMss1 = amorph1->specByRole<MethylOnBridgeCMss>(#{thrid_role_cm});
                                            if (methylOnBridgeCMss1)
                                            {
                                                methylOnBridgeCMss1->eachSymmetry([&dimerCLsCRi1, &neighbours1, &target](SpecificSpec *symmetricMethylOnBridgeCMss1) {
                                                    if (neighbours1[0] == symmetricMethylOnBridgeCMss1->atom(2) && neighbours1[1] == symmetricMethylOnBridgeCMss1->atom(3))
                                                    {
                                                        SpecificSpec *targets[3] = { target, symmetricMethylOnBridgeCMss1, dimerCLsCRi1 };
                                                        create<ForwardTwoSideDimersForm>(targets);
                                                    }
                                                });
                                            }
                                        }
                                    });
                                }
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

              it_behaves_like :check_code do
                let(:target_spec) { dept_activated_incoherent_dimer }
                let(:other_spec) { dept_right_activated_bridge }
                let(:thrid_spec) { dept_extra_activated_methyl_on_bridge }
                let(:find_algorithm) do
                  <<-CODE
    Atom *atom1 = target->atom(0);
    eachNeighbour(atom1, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cr}))
        {
            BridgeCRs *bridgeCRs1 = neighbour1->specByRole<BridgeCRs>(#{other_role_cr});
            if (bridgeCRs1)
            {
                Atom *atoms1[2] = { atom1, neighbour1 };
                eachNeighbours<2>(atoms1, &Diamond::cross_100, [&bridgeCRs1, &target](Atom **neighbours1) {
                    if (neighbours1[0]->is(#{thrid_role_cr}) && neighbours1[1]->is(#{thrid_role_cr}))
                    {
                        neighbourFrom(neighbours1, &Diamond::front_110_at, [&bridgeCRs1, &neighbours1, &target](Atom *neighbour2) {
                            if (neighbour2->is(#{thrid_role_cb}))
                            {
                                if (neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                                {
                                    neighbour2->eachAmorphNeighbour([&bridgeCRs1, &neighbours1, &target](Atom *amorph1) {
                                        if (amorph1->is(#{thrid_role_cm}))
                                        {
                                            MethylOnBridgeCMss *methylOnBridgeCMss1 = amorph1->specByRole<MethylOnBridgeCMss>(#{thrid_role_cm});
                                            if (methylOnBridgeCMss1)
                                            {
                                                methylOnBridgeCMss1->eachSymmetry([&bridgeCRs1, &neighbours1, &target](SpecificSpec *symmetricMethylOnBridgeCMss1) {
                                                    if (neighbours1[0] == symmetricMethylOnBridgeCMss1->atom(2) && neighbours1[1] == symmetricMethylOnBridgeCMss1->atom(3))
                                                    {
                                                        SpecificSpec *targets[3] = { bridgeCRs1, symmetricMethylOnBridgeCMss1, target };
                                                        create<ForwardTwoSideDimersForm>(targets);
                                                    }
                                                });
                                            }
                                        }
                                    });
                                }
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

              it_behaves_like :check_code do
                let(:target_spec) { dept_extra_activated_methyl_on_bridge }
                let(:other_spec) { dept_activated_incoherent_dimer }
                let(:thrid_spec) { dept_right_activated_bridge }
                let(:find_algorithm) do
                  <<-CODE
    target->eachSymmetry([](SpecificSpec *symmetricMethylOnBridgeCMss1) {
        Atom *atoms1[2] = { symmetricMethylOnBridgeCMss1->atom(2), symmetricMethylOnBridgeCMss1->atom(3) };
        eachNeighbours<2>(atoms1, &Diamond::cross_100, [&symmetricMethylOnBridgeCMss1](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cl}) && neighbours1[1]->is(#{thrid_role_cr}))
            {
                DimerCLsCRi *dimerCLsCRi1 = neighbours1[0]->specByRole<DimerCLsCRi>(#{other_role_cl});
                if (dimerCLsCRi1)
                {
                    BridgeCRs *bridgeCRs1 = neighbours1[1]->specByRole<BridgeCRs>(#{thrid_role_cr});
                    if (bridgeCRs1)
                    {
                        SpecificSpec *targets[3] = { bridgeCRs1, symmetricMethylOnBridgeCMss1, dimerCLsCRi1 };
                        create<ForwardTwoSideDimersForm>(targets);
                    }
                }
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
    Atom *atom1 = target->atom(2);
    eachNeighbour(atom1, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1 != target->atom(1))
        {
            if (neighbour1->is(#{role_cr}))
            {
                BridgeCRH *bridgeCRH1 = neighbour1->specByRole<BridgeCRH>(#{role_cr});
                if (bridgeCRH1)
                {
                    if (atom1 != bridgeCRH1->atom(1))
                    {
                        SpecificSpec *targets[2] = { bridgeCRH1, target };
                        create<ForwardHydrogenAbsFromGap>(targets);
                    }
                }
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
