require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionLookAroundBuilder, type: :algorithm do
          let(:generator) do
            stub_generator(
              base_specs: [dept_bridge_base, dept_dimer_base],
              specific_specs: [dept_activated_bridge, dept_activated_incoherent_bridge],
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end

          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:chunks) { lateral_reactions.map(&:chunk) }
          let(:classifier) { generator.classifier }
          let(:builder) { described_class.new(generator, subject) }
          subject { reaction.lateral_chunks }

          let(:typical_reaction) { dept_dimer_formation }

          let(:dimer_cr) { role(dept_dimer_base, :cr) }
          let(:bridge_ct) { role(dept_bridge_base, :ct) }

          let(:generating_class_name) { combined_lateral_reaction.class_name }
          let(:combined_lateral_reaction) do
            reaction.send(:children).find do |lr|
              !lr.chunk.original? && lr.chunk.parents.size == 0
            end
          end

          describe '#build' do
            describe 'just cross neighbours' do
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { target(0)->atom(0), target(1)->atom(0) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{dimer_cr}) && neighbours1[1]->is(#{dimer_cr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
        {
            LateralSpec *species[2] = { neighbours1[1]->specByRole<Dimer>(#{dimer_cr}), neighbours1[0]->specByRole<Dimer>(#{dimer_cr}) };
            if (species[0] && species[0] == species[1])
            {
                chunks[index++] = new #{class_name}(this, species[0]);
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
                let(:class_name) { generating_class_name }
              end
            end

            describe 'three sides neighbours' do
              it_behaves_like :check_code do
                let(:lateral_reactions) { [dept_end_lateral_df, dept_ewb_lateral_df] }
                let(:find_algorithm) do
                  <<-CODE
    Atom *atoms1[2] = { target(1)->atom(0), target(0)->atom(0) };
    eachNeighbour(atoms1[0], &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1 != atoms1[1] && neighbour1->is(#{bridge_ct}))
        {
            LateralSpec *specie = neighbour1->specByRole<Bridge>(#{bridge_ct});
            if (specie)
            {
                chunks[index++] = new #{generating_class_name}(this, specie);
            }
        }
    });
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{dimer_cr}) && neighbours1[1]->is(#{dimer_cr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
        {
            LateralSpec *species[2] = { neighbours1[1]->specByRole<Dimer>(#{dimer_cr}), neighbours1[0]->specByRole<Dimer>(#{dimer_cr}) };
            if (species[0] && species[0] == species[1])
            {
                chunks[index++] = new ForwardDimerFormationEndLateral(this, species[0]);
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
