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
            (target_spec.specific? ? specifics : bases) << target_spec
            if respond_to?(:other_spec)
              specs = other_spec.specific? ? specifics : bases
              specs << other_spec unless specs.find { |s| s.name == other_spec.name }
            end

            stub_generator(
              base_specs: bases.uniq,
              specific_specs: specifics.uniq,
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
    target->eachSymmetry([](SpecificSpec *specie1) {
        create<ForwardSierpinskiDrop>(specie1);
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
    Atom *anchor = target->atom(1);
    eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_ct}))
        {
            SpecificSpec *targets[2] = { target, neighbour1->specByRole<BridgeCTs>(#{other_role_ct}) };
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
    Atom *anchor = target->atom(0);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_ct}))
        {
            SpecificSpec *targets[2] = { target, neighbour1->specByRole<BridgeCTs>(#{other_role_ct}) };
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
    Atom *anchor = target->atom(0);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_ct}))
        {
            SpecificSpec *targets[2] = { neighbour1->specByRole<BridgeCTsi>(#{other_role_ct}), target };
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
    target->eachSymmetry([](SpecificSpec *specie1) {
        Atom *anchor = specie1->atom(2);
        eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour1) {
            if (neighbour1->is(#{other_role_cr}))
            {
                Atom *amorph1 = neighbour1->amorphNeighbour();
                if (amorph1->is(#{other_role_cm}))
                {
                    SpecificSpec *targets[2] = { amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm}), specie1 };
                    create<ForwardIntermedMigrDcFormation>(targets);
                }
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
    Atom *anchor = target->atom(1);
    eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cr}))
        {
            eachNeighbour(neighbour1, &Diamond::front_110, [&](Atom *neighbour2) {
                if (neighbour2->is(#{other_role_ct}) && neighbour1->hasBondWith(neighbour2))
                {
                    SpecificSpec *targets[2] = { target, neighbour2->specByRole<BridgeCTs>(#{other_role_ct}) };
                    create<ForwardIntermedMigrDcFormation>(targets);
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
    target->eachSymmetry([](SpecificSpec *specie1) {
        Atom *anchors[2] = { specie1->atom(2), specie1->atom(1) };
        eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cr}))
            {
                Atom *amorph1 = neighbours1[0]->amorphNeighbour();
                if (amorph1->is(#{other_role_cm}))
                {
                    MethylOnDimerCMs *specie2 = amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm});
                    if (neighbours1[1] != specie2->atom(4))
                    {
                        SpecificSpec *targets[2] = { specie2, specie1 };
                        create<ForwardIntermedMigrDhFormation>(targets);
                    }
                }
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
    Atom *anchors[2] = { target->atom(1), target->atom(4) };
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{other_role_cr}))
        {
            eachNeighbour(neighbours1[0], &Diamond::front_110, [&](Atom *neighbour1) {
                if (neighbour1->is(#{other_role_ct}) && neighbours1[0]->hasBondWith(neighbour1))
                {
                    BridgeCTs *specie1 = neighbour1->specByRole<BridgeCTs>(#{other_role_ct});
                    specie1->eachSymmetry([&](SpecificSpec *specie2) {
                        if (neighbours1[0] == specie2->atom(2) && neighbours1[1] != specie2->atom(1))
                        {
                            SpecificSpec *targets[2] = { target, specie2 };
                            create<ForwardIntermedMigrDhFormation>(targets);
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
              subject { dept_intermed_migr_df_formation }
              let(:target_spec) { dept_activated_bridge }
              let(:other_spec) { dept_activated_methyl_on_dimer }
              let(:find_algorithm) do
                <<-CODE
    target->eachSymmetry([](SpecificSpec *specie1) {
        Atom *anchors[2] = { specie1->atom(2), specie1->atom(1) };
        eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cl}) && neighbours1[0]->hasBondWith(neighbours1[1]))
            {
                Atom *amorph1 = neighbours1[0]->amorphNeighbour();
                if (amorph1->is(#{other_role_cm}))
                {
                    SpecificSpec *targets[2] = { amorph1->specByRole<MethylOnDimerCMs>(#{other_role_cm}), specie1 };
                    create<ForwardIntermedMigrDfFormation>(targets);
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
            Atom *neighbour1 = crystalBy(neighbours1[1])->atom(Diamond::front_110_at(neighbours1[0], neighbours1[1]));
            if (neighbour1 && neighbour1->is(#{other_role_ct}) && neighbours1[0]->hasBondWith(neighbour1) && neighbours1[1]->hasBondWith(neighbour1))
            {
                SpecificSpec *targets[2] = { target, neighbour1->specByRole<BridgeCTs>(#{other_role_ct}) };
                create<ForwardIntermedMigrDfFormation>(targets);
            }
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
                SpecificSpec *targets[2] = { neighbours1[1]->specByRole<DimerCRs>(#{other_role_cr}), specie1 };
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
            Atom *neighbour1 = crystalBy(neighbours1[1])->atom(Diamond::front_110_at(neighbours1[0], neighbours1[1]));
            if (neighbour1 && neighbour1->is(#{other_role_cb}) && neighbours1[0]->hasBondWith(neighbour1) && neighbours1[1]->hasBondWith(neighbour1))
            {
                Atom *amorph1 = neighbour1->amorphNeighbour();
                if (amorph1->is(#{other_role_cm}))
                {
                    SpecificSpec *targets[2] = { target, amorph1->specByRole<MethylOnBridgeCMs>(#{other_role_cm}) };
                    create<ForwardMethylIncorporation>(targets);
                }
            }
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
            if (neighbours1[1] != specie1->atom(1))
            {
                SpecificSpec *targets[3] = { target, specie1, neighbours1[1]->specByRole<BridgeCRs>(#{other_role_cr}) };
                create<ForwardMethylToGap>(targets);
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
        if (neighbour1->is(#{role_cr}))
        {
            if (neighbour1 != target->atom(1))
            {
                Atom *anchors1[2] = { neighbour1, anchor };
                eachNeighbours<2>(anchors1, &Diamond::cross_100, [&](Atom **neighbours1) {
                    if (neighbours1[0]->is(#{other_role_cr}) && neighbours1[1]->is(#{other_role_cr}))
                    {
                        Atom *neighbour2 = crystalBy(neighbours1[1])->atom(Diamond::front_110_at(neighbours1[0], neighbours1[1]));
                        if (neighbour2 && neighbour2->is(#{other_role_cb}) && neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                        {
                            Atom *amorph1 = neighbour2->amorphNeighbour();
                            if (amorph1->is(#{other_role_cm}))
                            {
                                SpecificSpec *targets[3] = { amorph1->specByRole<MethylOnBridgeCMss>(#{other_role_cm}), anchors1[0]->specByRole<BridgeCRs>(#{role_cr}), target };
                                create<ForwardMethylToGap>(targets);
                            }
                        }
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
              let(:specific_specs) do
                [
                  dept_extra_activated_methyl_on_bridge,
                  dept_activated_incoherent_dimer,
                  dept_right_activated_bridge
                ]
              end
              subject { dept_two_dimers_form }

              it_behaves_like :check_code do
                let(:target_spec) { dept_right_activated_bridge }
                let(:other_spec) { dept_activated_incoherent_dimer }
                let(:thrid_spec) { dept_extra_activated_methyl_on_bridge }
                let(:find_algorithm) do
                  <<-CODE
    Atom *anchor = target->atom(2);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cl}) && !anchor->hasBondWith(neighbour1))
        {
            Atom *anchors1[2] = { neighbour1, anchor };
            eachNeighbours<2>(anchors1, &Diamond::cross_100, [&](Atom **neighbours1) {
                if (neighbours1[0]->is(#{thrid_role_cr}) && neighbours1[1]->is(#{thrid_role_cr}))
                {
                    Atom *neighbour2 = crystalBy(neighbours1[1])->atom(Diamond::front_110_at(neighbours1[0], neighbours1[1]));
                    if (neighbour2 && neighbour2->is(#{thrid_role_cb}) && neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                    {
                        Atom *amorph1 = neighbour2->amorphNeighbour();
                        if (amorph1->is(#{thrid_role_cm}))
                        {
                            SpecificSpec *targets[3] = { anchors1[0]->specByRole<DimerCLsCRi>(#{other_role_cl}), amorph1->specByRole<MethylOnBridgeCMss>(#{thrid_role_cm}), target };
                            create<ForwardTwoDimersForm>(targets);
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
                let(:target_spec) { dept_activated_incoherent_dimer }
                let(:other_spec) { dept_right_activated_bridge }
                let(:thrid_spec) { dept_extra_activated_methyl_on_bridge }
                let(:find_algorithm) do
                  <<-CODE
    Atom *anchor = target->atom(3);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{other_role_cr}) && !anchor->hasBondWith(neighbour1))
        {
            Atom *anchors1[2] = { anchor, neighbour1 };
            eachNeighbours<2>(anchors1, &Diamond::cross_100, [&](Atom **neighbours1) {
                if (neighbours1[0]->is(#{thrid_role_cr}) && neighbours1[1]->is(#{thrid_role_cr}))
                {
                    Atom *neighbour2 = crystalBy(neighbours1[1])->atom(Diamond::front_110_at(neighbours1[0], neighbours1[1]));
                    if (neighbour2 && neighbour2->is(#{thrid_role_cb}) && neighbours1[0]->hasBondWith(neighbour2) && neighbours1[1]->hasBondWith(neighbour2))
                    {
                        Atom *amorph1 = neighbour2->amorphNeighbour();
                        if (amorph1->is(#{thrid_role_cm}))
                        {
                            SpecificSpec *targets[3] = { target, amorph1->specByRole<MethylOnBridgeCMss>(#{thrid_role_cm}), anchors1[1]->specByRole<BridgeCRs>(#{other_role_cr}) };
                            create<ForwardTwoDimersForm>(targets);
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
                let(:target_spec) { dept_extra_activated_methyl_on_bridge }
                let(:other_spec) { dept_activated_incoherent_dimer }
                let(:thrid_spec) { dept_right_activated_bridge }
                let(:find_algorithm) do
                  <<-CODE
    target->eachSymmetry([](SpecificSpec *specie1) {
        Atom *anchors[2] = { specie1->atom(2), specie1->atom(3) };
        eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours1) {
            if (neighbours1[0]->is(#{other_role_cl}) && neighbours1[1]->is(#{thrid_role_cr}) && !neighbours1[0]->hasBondWith(neighbours1[1]))
            {
                SpecificSpec *targets[3] = { neighbours1[0]->specByRole<DimerCLsCRi>(#{other_role_cl}), specie1, neighbours1[1]->specByRole<BridgeCRs>(#{thrid_role_cr}) };
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
        if (neighbour1->is(#{role_cr}))
        {
            if (neighbour1 != target->atom(1))
            {
                SpecificSpec *targets[2] = { target, neighbour1->specByRole<BridgeCRH>(#{role_cr}) };
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
