require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionLookAroundBuilder, type: :algorithm do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:generator) do
            stub_generator(
              base_specs: base_specs,
              specific_specs: specific_specs,
              typical_reactions: [subject],
              lateral_reactions: lateral_reactions)
          end

          let(:chunks) { lateral_reactions.map(&:chunk) }
          let(:classifier) { generator.classifier }
          let(:code_reaction) { generator.reaction_class(subject.name) }
          let(:builder) { described_class.new(generator, code_reaction, chunks) }

          let(:dimer_cr) { role(dept_dimer_base, keyname) }
          let(:bridge_ct) { role(dept_bridge_base, keyname) }

          describe '#build' do
            it_behaves_like :check_code do
              subject { dept_dimer_formation }
              let(:lateral_reactions) { [dept_end_lateral_df] }
              let(:find_algorithm) do
                <<-CODE
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    eachNeighbours<2>(atoms, &Diamond::cross_100, [&](Atom **neighbours) {
        if (neighbours[0]->is(#{dimer_cr}) && neighbours[1]->is(#{dimer_cr}))
        {
            LateralSpec *species[2] = { neighbours[0]->specByRole<Dimer>(#{dimer_cr}), neighbours[1]->specByRole<Dimer>(#{dimer_cr}) };
            if (species[0] && species[0] == species[1])
            {
                chunks[index++] = new ForwardDimerFormationAtEnd(this, species[0]);
            }
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_formation }
              let(:lateral_reactions) { [dept_middle_lateral_df] }
              let(:find_algorithm) do
                <<-CODE
    Atom *atom1 = target(0)->atom(0);
    auto neighbours1 = crystalBy(atom1)->cross_100(atom1);
    if (neighbours1[0]->is(#{dimer_cr}) && neighbours1[1]->is(#{dimer_cr}))
    {
        Atom *atom2 = target(1)->atom(0);
        auto neighbours2 = crystalBy(atom2)->cross_100(atom2);
        if (neighbours2[0]->is(#{dimer_cr}) && neighbours2[1]->is(#{dimer_cr}))
        {
            LateralSpec *species1[4] = { neighbours1[0]->specByRole<Dimer>(#{dimer_cr}), neighbours1[1]->specByRole<Dimer>(#{dimer_cr}), neighbours2[0]->specByRole<Dimer>(#{dimer_cr}), neighbours2[1]->specByRole<Dimer>(#{dimer_cr}) };
            if (species1[0] && species1[0] == species1[1] && species1[2] && species1[2] == species1[3])
            {
                LateralSpec *species2[2] = { species1[0], species1[2] };
                chunks[index++] = new ForwardDimerFormationInMiddle(this, species2);
            }
        }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_formation }
              let(:lateral_reactions) { [dept_wb_lateral_df] }
              let(:combined_lateral_reactions) do
                subject.children.select { |chd| chd.is_a?(CombinedLateralReaction) }
              end
              let(:ind_chunk_ids) { combined_lateral_reactions.map(&:chunk) }

              let(:find_algorithm) do
                <<-CODE
    // TODO: independent chunk should be generated and then used
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    eachNeighbour(atoms[0], &Diamond::front_100, [&](Atom *neighbour) {
        if (neighbour != atoms[1] && neighbour->is(#{bridge_ct}))
        {
            eachNeighbours<2>(atoms, &Diamond::cross_100, [&](Atom **neighbours) {
                if (neighbours[0]->is(#{dimer_cr}) && neighbours[1]->is(#{dimer_cr}))
                {
                    LateralSpec *species[3] = { neighbour->specByRole<Bridge>(#{bridge_ct}), neighbours[0]->specByRole<Dimer>(#{dimer_cr}), neighbours[1]->specByRole<Dimer>(#{dimer_cr}) };
                    if (species[0] && species[1] && species[1] == species[2])
                    {
                        chunks[index++] = new ForwardDimerFormationAtEndWithBridge(this, species);
                    }
                }
            });
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { dept_dimer_formation }
              let(:lateral_reactions) { [dept_end_lateral_df, dept_ewb_lateral_df] }
              let(:combined_lateral_reactions) do
                subject.children.select { |chd| chd.is_a?(CombinedLateralReaction) }
              end
              let(:ind_chunk_id) { combined_lateral_reactions.first.chunk }

              let(:find_algorithm) do
                <<-CODE
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    eachNeighbours<2>(atoms, &Diamond::cross_100, [&](Atom **neighbours) {
        if (neighbours[0]->is(#{dimer_cr}) && neighbours[1]->is(#{dimer_cr}))
        {
            LateralSpec *species[2] = { neighbours[0]->specByRole<Dimer>(#{dimer_cr}), neighbours[1]->specByRole<Dimer>(#{dimer_cr}) };
            if (species[0] && species[0] == species[1])
            {
                chunks[index++] = new ForwardDimerFormationAtEnd(this, species[0]);
            }
        }
    });
    eachNeighbour(atoms[0], &Diamond::front_100, [&](Atom *neighbour) {
        if (neighbour != atoms[1] && neighbour->is(#{bridge_ct}))
        {
            LateralSpec *specie = neighbour->specByRole<Bridge>(#{bridge_ct});
            if (specie)
            {
                chunks[index++] = new CombinedForwardDimerFormationChunkNo#{ind_chunk_id}(this, specie);
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
