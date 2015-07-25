require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionCheckLateralsBuilder, type: :algorithm do
          let(:generator) do
            stub_generator(
              base_specs: [dept_bridge_base, dept_dimer_base],
              specific_specs: [
                dept_activated_bridge, dept_activated_incoherent_bridge
              ],
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end

          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:specie) { generator.specie_class(spec.name) }
          let(:classifier) { generator.classifier }
          let(:builder) { reaction.check_laterals_builder_from(specie) }
          let(:sidepiece_specs) { subject.sidepiece_specs.to_a }
          subject { reaction.lateral_chunks }

          let(:typical_reaction) { dept_dimer_formation }

          let(:lateral_bridge) { (sidepiece_specs - [lateral_dimer]).first }
          let(:lateral_dimer) do
            sidepiece_specs.select { |spec| spec.name == :dimer }.first
          end

          let(:ab_ct) { role(dept_activated_bridge, :ct) }
          let(:aib_ct) { role(dept_activated_incoherent_bridge, :ct) }

          let(:generating_class_names) { combined_lateral_reaction.map(&:class_name) }
          let(:combined_lateral_reaction) do
            subject.unconcrete_affixes - lateral_reactions.map do |lr|
              generator.reaction_class(lr.name)
            end
          end

          describe '#build' do
            describe 'just cross neighbours' do
              let(:spec) { lateral_dimer }
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { target->atom(0), target->atom(3) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{aib_ct}) && neighbours1[1]->is(#{ab_ct}))
        {
            SpecificSpec *species[2] = { neighbours1[0]->specByRole<BridgeCTsi>(#{aib_ct}), neighbours1[1]->specByRole<BridgeCTs>(#{ab_ct}) };
            if (species[0] && species[1])
            {
                {
                    #{class_name} *nbrReaction = species[0]->checkoutReactionWith<#{class_name}>(species[1]);
                    if (nbrReaction)
                    {
                        assert(!target->haveReaction(nbrReaction));
                        SingleLateralReaction *chunk = new #{class_name}(nbrReaction->parent(), target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
                {
                    ForwardDimerFormation *nbrReaction = species[0]->checkoutReactionWith<ForwardDimerFormation>(species[1]);
                    if (nbrReaction)
                    {
                        SingleLateralReaction *chunk = new #{class_name}(nbrReaction, target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
            }
        }
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
    Atom *atoms1[2] = { target->atom(0), target->atom(3) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{aib_ct}) && neighbours1[1]->is(#{ab_ct}))
        {
            SpecificSpec *species[2] = { neighbours1[0]->specByRole<BridgeCTsi>(#{aib_ct}), neighbours1[1]->specByRole<BridgeCTs>(#{ab_ct}) };
            if (species[0] && species[1])
            {
                {
                    #{class_name_with_bridge} *nbrReaction = species[0]->checkoutReactionWith<#{class_name_with_bridge}>(species[1]);
                    if (nbrReaction)
                    {
                        assert(!target->haveReaction(nbrReaction));
                        SingleLateralReaction *chunk = new #{class_name_with_dimer}(nbrReaction->parent(), target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
                {
                    #{class_name_with_dimer} *nbrReaction = species[0]->checkoutReactionWith<#{class_name_with_dimer}>(species[1]);
                    if (nbrReaction)
                    {
                        assert(!target->haveReaction(nbrReaction));
                        SingleLateralReaction *chunk = new #{class_name_with_dimer}(nbrReaction->parent(), target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
                {
                    ForwardDimerFormationEwbLateral *nbrReaction = species[0]->checkoutReactionWith<ForwardDimerFormationEwbLateral>(species[1]);
                    if (nbrReaction)
                    {
                        assert(!target->haveReaction(nbrReaction));
                        SingleLateralReaction *chunk = new #{class_name_with_dimer}(nbrReaction->parent(), target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
                {
                    ForwardDimerFormation *nbrReaction = species[0]->checkoutReactionWith<ForwardDimerFormation>(species[1]);
                    if (nbrReaction)
                    {
                        SingleLateralReaction *chunk = new #{class_name_with_dimer}(nbrReaction, target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
            }
        }
    });
                  CODE
                end
              end

              it_behaves_like :check_code do
                let(:spec) { lateral_bridge }
                let(:find_algorithm) do
                  <<-CODE
    Atom *atom1 = target->atom(0);
    eachNeighbour(atom1, &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{aib_ct}))
        {
            SpecificSpec *specie = neighbour1->specByRole<BridgeCTsi>(#{aib_ct});
            if (specie)
            {
                {
                    #{class_name_with_dimer} *nbrReaction = specie->checkoutReaction<#{class_name_with_dimer}>();
                    if (nbrReaction)
                    {
                        assert(!target->haveReaction(nbrReaction));
                        SingleLateralReaction *chunk = new #{class_name_with_bridge}(nbrReaction->parent(), target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
                {
                    #{class_name_with_two_dimer} *nbrReaction = specie->checkoutReaction<#{class_name_with_two_dimer}>();
                    if (nbrReaction)
                    {
                        assert(!target->haveReaction(nbrReaction));
                        SingleLateralReaction *chunk = new #{class_name_with_bridge}(nbrReaction->parent(), target);
                        nbrReaction->concretize(chunk);
                        return;
                    }
                }
                {
                    ForwardDimerFormation *nbrReaction = specie->checkoutReaction<ForwardDimerFormation>();
                    if (nbrReaction)
                    {
                        SingleLateralReaction *chunk = new #{class_name_with_bridge}(nbrReaction, target);
                        nbrReaction->concretize(chunk);
                        return;
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
end
