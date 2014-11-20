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

            stub_generator(
              base_specs: bases,
              specific_specs: specifics,
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
    eachNeighbour(anchor, &Diamond::cross_100, [&](Atom *neighbour) {
        if (neighbour->is(#{other_role_ct}))
        {
            SpecificSpec *targets[2] = { target, neighbour->specByRole<BridgeCTs>(#{other_role_ct}) };
            create<ReverseSierpinskiDrop>(targets);
        }
    });
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
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour) {
        if (neighbour->is(#{other_role_ct}))
        {
            SpecificSpec *targets[2] = { target, neighbour->specByRole<BridgeCTs>(#{other_role_ct}) };
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
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour) {
        if (neighbour->is(#{other_role_ct}))
        {
            SpecificSpec *targets[2] = { neighbour->specByRole<BridgeCTsi>(#{other_role_ct}), target };
            create<ForwardDimerFormation>(targets);
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
    Atom *anchors[2] = { target->atom(3), target->atom(2) };
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours) {
        if (neighbours[0]->is(#{other_role_cl}) && neighbours[1]->is(#{other_role_cl}) && neighbours[0]->hasBondWith(neighbours[1]))
        {
            for (int i = 0; i < 2; ++i)
            {
                if (neighbours[i]->is(#{other_role_cr}))
                {
                    SpecificSpec *targets[2] = { neighbours[i]->specByRole<DimerCRs>(#{other_role_cr}), target };
                    create<ForwardMethylIncorporation>(targets);
                }
            }
        }
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
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&](Atom **neighbours) {
        if (neighbours[0]->is(#{other_role_cr}) && neighbours[1]->is(#{other_role_cr}))
        {
            Atom *neighbour1 = crystalBy(neighbours[1])->atom(Diamond::front_110_at(neighbours[0], neighbours[1]));
            if (neighbour1 && neighbour1->is(#{other_role_cb}) && neighbours[0]->hasBondWith(neighbour1) && neighbours[1]->hasBondWith(neighbour1))
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
              subject { dept_hydrogen_abs_from_gap }
              let(:target_spec) do
                Organizers::DependentSpecificSpec.new(subject.source.first)
              end
              let(:other_spec) do
                Organizers::DependentSpecificSpec.new(subject.source.last)
              end

              let(:find_algorithm) do
                <<-CODE
    Atom *anchor = target->atom(2);
    eachNeighbour(anchor, &Diamond::front_100, [&](Atom *neighbour) {
        if (neighbour->is(#{other_role_cr}) && neighbour != target->atom(1))
        {
            SpecificSpec *targets[2] = { target, neighbour->specByRole<BridgeCRH>(#{other_role_cr}) };
            create<ForwardHydrogenAbsFromGap>(targets);
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
