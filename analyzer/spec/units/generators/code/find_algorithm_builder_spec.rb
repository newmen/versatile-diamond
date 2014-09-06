require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe FindAlgorithmBuilder, use: :engine_generator do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:generator) do
          stub_generator(base_specs: base_specs, specific_specs: specific_specs)
        end
        let(:classifier) { generator.classifier }

        let(:code_specie) { generator.specie_class(subject.name) }
        let(:builder) { described_class.new(generator, code_specie) }

        describe '#pure_essence && #central_anchors' do
          def role(spec, keyname)
            classifier.index(spec, spec.spec.atom(keyname))
          end

          [:ct, :cr, :cl, :cb, :cm, :cc, :c1, :c2].each do |keyname|
            let(keyname) { subject.spec.atom(keyname) }
            let(:"role_#{keyname}") { role(subject, keyname) }
          end

          let(:b_ct) { role(dept_bridge_base, :ct) }

          shared_examples_for :check_essence_and_anchors do
            it { expect(builder.pure_essence).to eq(essence) }
            it { expect(builder.central_anchors).to eq(central_anchors) }
            it { expect(builder.build).to eq(find_algorithm) }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { dept_bridge_base }
            let(:base_specs) { [subject, dept_dimer_base] }

            let(:essence) { { ct => [[cl, bond_110_cross], [cr, bond_110_cross]] } }
            let(:central_anchors) { [[ct]] }
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

          it_behaves_like :check_essence_and_anchors do
            subject { dept_right_hydrogenated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }

            let(:essence) { { cr => [] } }
            let(:central_anchors) { [[cr]] }
            let(:find_algorithm) do
              <<-CODE
    parent->eachSymmetry([](ParentSpec *specie) {
        Atom *anchor = specie->atom(0);
        if (anchor->is(#{role_cr}))
        {
            if (!anchor->hasRole(BRIDGE_CRH, #{role_cr}))
            {
                create<BridgeCRH>(specie);
            }
        }
    });
              CODE
            end
          end

          it_behaves_like :check_essence_and_anchors do
            subject { dept_methyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:specific_specs) { [dept_activated_methyl_on_bridge] }

            let(:essence) { { cb => [[cm, free_bond]] } }
            let(:central_anchors) { [[cb]] }
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

          it_behaves_like :check_essence_and_anchors do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }

            let(:essence) { { cb => [], cm => [] } }
            let(:central_anchors) { [[cb, cm]] }
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

          it_behaves_like :check_essence_and_anchors do
            subject { dept_high_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }

            let(:essence) { { cb => [[cm, free_bond]] } }
            let(:central_anchors) { [[cb]] }
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

          it_behaves_like :check_essence_and_anchors do
            subject { dept_vinyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }

            let(:essence) { { cb => [[c1, free_bond]], c1 => [[c2, free_bond]] } }
            let(:central_anchors) { [[cb]] }
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

          it_behaves_like :check_essence_and_anchors do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }

            let(:essence) { { cr => [[cl, bond_100_front]] } }
            let(:central_anchors) { [[cr]] }
            let(:find_algorithm) do
              <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(DIMER, #{role_cr}))
        {
            eachNeighbour(anchor, &Diamond::front_100, [anchor](Atom *neighbour) {
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

          it_behaves_like :check_essence_and_anchors do
            subject { dept_methyl_on_dimer_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end

            let(:essence) do
              {
                cr => [[cl, bond_100_front]],
                cl => [[cr, bond_100_front]]
              }
            end
            let(:central_anchors) { [[cr], [cl]] }

            let(:mob_cb) { role(dept_methyl_on_bridge_base, :cb) }
            let(:find_algorithm) do
              <<-CODE
    if (anchor->is(#{role_cr}))
    {
        if (!anchor->hasRole(METHYL_ON_DIMER, #{role_cr}))
        {
            eachNeighbour(anchor, &Diamond::front_100, [anchor](Atom *neighbour) {
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
            eachNeighbour(anchor, &Diamond::front_100, [anchor](Atom *neighbour) {
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

          it_behaves_like :check_essence_and_anchors do
            subject { dept_two_methyls_on_dimer_base }
            let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }

            let(:essence) { { cr => [[c1, free_bond]], cl => [[c2, free_bond]] } }
            let(:central_anchors) { [[cl, cr]] }
            let(:find_algorithm) do
              <<-CODE
    Atom *anchors[2] = { parent->atom(3), parent->atom(0) };
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
                    Atom *additionalAtoms[2] = { amorph2, amorph1 };
                    create<TwoMethylsOnDimer>(additionalAtoms, parent);
                }
            }
        }
    }
              CODE
            end
          end

          it_behaves_like :check_essence_and_anchors do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }

            let(:essence) { { ct => [], cc => [] } }
            let(:central_anchors) { [[ct]] }

            let(:b_cr) { role(dept_bridge_base, :cr) }
            let(:find_algorithm) do
              <<-CODE
    if (anchor->is(#{role_cc}))
    {
        if (!anchor->hasRole(THREE_BRIDGES, #{role_cc}))
        {
            anchor->eachSpecByRole<Bridge>(#{b_cr}, [anchor](Bridge *target) {
                target->eachSymmetry([anchor, target](ParentSpec *specie) {
                    if (specie->atom(2) == anchor)
                    {
                        Atom *atom1 = specie->atom(1);
                        if (atom1->is(#{b_cr}))
                        {
                            Bridge *external = anchor->selectSpecByRole<Bridge>(#{b_cr}, [target](Bridge *other) {
                                return other == target;
                            });

                            ParentSpec *last = external->selectSymmetry([anchor](ParentSpec *other) {
                                return other->atom(1) == anchor;
                            });

                            ParentSpec *parents[3] = { atom1->specByRole<Bridge>(#{b_ct}), specie, last };
                            create<TwoBridges>(parents);
                        }
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
