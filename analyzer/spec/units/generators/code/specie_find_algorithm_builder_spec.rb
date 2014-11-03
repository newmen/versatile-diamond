require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe SpecieFindAlgorithmBuilder, use: :engine_generator do
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
        let(:builder) { described_class.new(generator, code_specie) }

        describe '#build' do
          def role(spec, keyname)
            classifier.index(spec, spec.spec.atom(keyname))
          end

          [:ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2, :ctl, :ctr].each do |keyname|
            let(keyname) { subject.spec.atom(keyname) }
            let(:"role_#{keyname}") { role(subject, keyname) }
          end

          [:ct, :cr].each do |keyname|
            let(:"b_#{keyname}") { role(dept_bridge_base, keyname) }
          end
          let(:mob_cb) { role(dept_methyl_on_bridge_base, :cb) }

          shared_examples_for :check_code do
            it { expect(builder.build).to eq(find_algorithm) }
          end

          it_behaves_like :check_code do
            subject { dept_bridge_base }
            let(:base_specs) { [subject, dept_dimer_base] }
            let(:find_algorithm) do
              <<-CODE
    if (anchor->is(#{role_ct}))
    {
        if (!anchor->hasRole(BRIDGE, #{role_ct}))
        {
            auto neighbours = crystalBy(anchor)->cross_110(anchor);
            if (neighbours.all() && neighbours[0]->is(#{role_cr}) && neighbours[1]->is(#{role_cr}) && anchor->hasBondWith(neighbours[0]) && anchor->hasBondWith(neighbours[1]))
            {
                Atom *atoms[3] = { anchor, neighbours[0], neighbours[1] };
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
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour) {
                if (neighbour->is(#{role_cr}) && anchor->hasBondWith(neighbour))
                {
                    ParentSpec *parents[2] = { anchor->specByRole<Bridge>(#{b_ct}), neighbour->specByRole<Bridge>(#{b_ct}) };
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
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour) {
                if (neighbour->is(#{role_cl}) && anchor->hasBondWith(neighbour))
                {
                    ParentSpec *parents[2] = { anchor->specByRole<MethylOnBridge>(#{mob_cb}), neighbour->specByRole<Bridge>(#{b_ct}) };
                    create<MethylOnDimer>(parents);
                }
            });
        }
    }
    else if (anchor->is(#{role_cl}))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER, #{role_cl}))
        {
            eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour) {
                if (neighbour->is(#{role_cr}) && anchor->hasBondWith(neighbour))
                {
                    ParentSpec *parents[2] = { neighbour->specByRole<MethylOnBridge>(#{mob_cb}), anchor->specByRole<Bridge>(#{b_ct}) };
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
                eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour) {
                    if (neighbour->is(#{role_ctr}) && !anchor->hasBondWith(neighbour))
                    {
                        if (neighbour->hasBondWith(amorph1))
                        {
                            ParentSpec *parents[2] = { anchor->specByRole<Bridge>(#{b_ct}), neighbour->specByRole<Bridge>(#{b_ct}) };
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

            let(:mob_cm) { role(dept_methyl_on_bridge_base, :cm) }
            let(:find_algorithm) do
              <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_BRIDGES, #{role_cm}))
        {
            auto species = anchor->specsByRole<MethylOnBridge, 2>(#{mob_cm});
            if (species.all())
            {
                Atom *atoms[2] = { species[0]->atom(1), species[1]->atom(1) };
                eachNeighbour(atoms[0], &Diamond::cross_100, [&](Atom *neighbour) {
                    if (atoms[1] == neighbour && !atoms[0]->hasBondWith(neighbour))
                    {
                        ParentSpec *parents[2] = { species[0], species[1] };
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
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_dimer_base, subject] }

            let(:mod_cm) { role(dept_methyl_on_dimer_base, :cm) }
            let(:find_algorithm) do
              <<-CODE
    if (anchor->is(#{role_cm}))
    {
        if (!anchor->hasRole(CROSS_BRIDGE_ON_DIMERS, #{role_cm}))
        {
            auto species = anchor->specsByRole<MethylOnDimer, 2>(#{mod_cm});
            if (species.all())
            {
                Atom *atoms[4] = { species[0]->atom(4), species[0]->atom(1), species[1]->atom(4), species[1]->atom(1) };
                Atom *anchors[2] = { atoms[2], atoms[3] };
                eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours) {
                    if (atoms[0] == neighbours[0] && atoms[1] == neighbours[1] && !anchors[0]->hasBondWith(neighbours[0]) && !anchors[1]->hasBondWith(neighbours[1]))
                    {
                        ParentSpec *parents[2] = { species[0], species[1] };
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

            let(:d_cr) { role(dept_dimer_base, :cr) }
            let(:find_algorithm) do
              <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(BRIDGE_WITH_DIMER, #{role_cr}))
        {
            anchor->eachSpecByRole<Dimer>(#{d_cr}, [&](Dimer *target1) {
                target1->eachSymmetry([&](ParentSpec *specie1) {
                    if (anchor == specie1->atom(3))
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
        end
      end

    end
  end
end
