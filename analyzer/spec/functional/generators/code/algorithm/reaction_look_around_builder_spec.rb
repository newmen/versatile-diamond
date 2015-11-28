require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionLookAroundBuilder, type: :algorithm, use: :chunks do
          let(:generator) do
            stub_generator(
              base_specs: respond_to?(:base_specs) ? base_specs : [],
              specific_specs: respond_to?(:specific_specs) ? specific_specs : [],
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end

          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:classifier) { generator.classifier }
          let(:builder) { described_class.new(generator, lateral_chunks) }
          let(:lateral_chunks) { reaction.lateral_chunks }

          let(:combined_lateral_reactions) do
            lateral_chunks.unconcrete_affixes - lateral_reactions.map do |lr|
              generator.reaction_class(lr.name)
            end
          end

          describe '#build' do
            describe 'dimers row formation' do
              let(:typical_reaction) { dept_dimer_formation }
              let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
              let(:specific_specs) do
                [dept_activated_bridge, dept_activated_incoherent_bridge]
              end

              let(:dimer_cr) { role(dept_dimer_base, :cr) }
              let(:bridge_ct) { role(dept_bridge_base, :ct) }

              let(:generating_class_name) do
                combined_lateral_reactions.first.class_name
              end

              describe 'just cross neighbours' do
                let(:find_algorithm) do
                  <<-CODE
    Atom *atoms1[2] = { target(0)->atom(0), target(1)->atom(0) };
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{dimer_cr}) && neighbours1[1]->is(#{dimer_cr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
        {
            LateralSpec *species1[2] = { neighbours1[0]->specByRole<Dimer>(#{dimer_cr}), neighbours1[1]->specByRole<Dimer>(#{dimer_cr}) };
            if (species1[0] && species1[0] == species1[1])
            {
                chunks[index++] = new #{class_name}(this, species1[0]);
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
    eachNeighbours<2>(atoms1, &Diamond::cross_100, [&](Atom **neighbours1) {
        if (neighbours1[0]->is(#{dimer_cr}) && neighbours1[1]->is(#{dimer_cr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
        {
            LateralSpec *species1[2] = { neighbours1[0]->specByRole<Dimer>(#{dimer_cr}), neighbours1[1]->specByRole<Dimer>(#{dimer_cr}) };
            if (species1[0] && species1[0] == species1[1])
            {
                chunks[index++] = new ForwardDimerFormationEndLateral(this, species1[0]);
            }
        }
    });
    eachNeighbour(atoms1[0], &Diamond::front_100, [&](Atom *neighbour1) {
        if (neighbour1->is(#{bridge_ct}))
        {
            if (neighbour1 != atoms1[1])
            {
                LateralSpec *specie1 = neighbour1->specByRole<Bridge>(#{bridge_ct});
                if (specie1)
                {
                    chunks[index++] = new #{generating_class_name}(this, specie1);
                }
            }
        }
    });
                    CODE
                  end
                end
              end
            end

            describe 'many similar activated bridges' do
              let(:typical_reaction) { dept_symmetric_dimer_formation }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_activated_bridge] }

              let(:ab_ct) { role(dept_activated_bridge, :ct) }

              let(:front_cmb_name) { cmb_reaction_class_name_by(position_100_front) }
              let(:cross_cmb_name) { cmb_reaction_class_name_by(position_100_cross) }

              let(:find_algorithm) do
                <<-CODE
    Atom *atoms1[2] = { #{target_atoms_definition} };
    for (uint ae1 = 0; ae1 < 2; ++ae1)
    {
        eachNeighbour(atoms1[ae1], &Diamond::cross_100, [&](Atom *neighbour1) {
            if (neighbour1->is(#{ab_ct}))
            {
                LateralSpec *specie1 = neighbour1->specByRole<BridgeCTs>(#{ab_ct});
                if (specie1)
                {
                    chunks[index++] = new #{cross_cmb_name}(this, specie1);
                }
            }
        });
        eachNeighbour(atoms1[ae1], &Diamond::front_100, [&](Atom *neighbour1) {
            if (neighbour1->is(#{ab_ct}))
            {
                if (neighbour1 != atoms1[ae1-1])
                {
                    LateralSpec *specie1 = neighbour1->specByRole<BridgeCTs>(#{ab_ct});
                    if (specie1)
                    {
                        chunks[index++] = new #{front_cmb_name}(this, specie1);
                    }
                }
            }
        });
    }
                CODE
              end

              it_behaves_like :check_code do
                let(:lateral_reactions) { [dept_small_ab_lateral_sdf] }
                let(:target_atoms_definition) do
                  'target(1)->atom(0), target(0)->atom(0)'
                end
              end

              it_behaves_like :check_code do
                let(:lateral_reactions) { [dept_big_ab_lateral_sdf] }
                let(:target_atoms_definition) do
                  'target(0)->atom(0), target(1)->atom(0)'
                end
              end

              it_behaves_like :check_code do
                let(:lateral_reactions) do
                  [dept_small_ab_lateral_sdf, dept_big_ab_lateral_sdf]
                end
                let(:target_atoms_definition) do
                  'target(1)->atom(0), target(0)->atom(0)'
                end
              end
            end

            describe 'methyl incorporation near edge' do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
              end
              let(:specific_specs) do
                [dept_activated_methyl_on_bridge, dept_activated_dimer]
              end
              let(:typical_reaction) { dept_methyl_incorporation }
              let(:lateral_reactions) { [dept_de_lateral_mi] }

              let(:amob) { (lateral_chunks.target_specs - [admr]).first }
              let(:admr) do
                lateral_chunks.target_specs.find { |s| s.name == :'dimer(cr: *)' }
              end

              let(:amob_cb) { role(amob, :cb) }
              let(:admr_cl) { role(admr, :cl) }

              let(:edge_dimer) { lateral_chunks.sidepiece_specs.first }
              let(:edmr_cr) { role(edge_dimer, :cr) }

              it_behaves_like :check_code do
                let(:find_algorithm) do
                  <<-CODE
    Atom *atoms1[2] = { target(0)->atom(1), target(1)->atom(3) };
    eachNeighbour(atoms1[1], &Diamond::front_110, [&](Atom *neighbour1) {
        if (neighbour1->is(18) && atoms1[1]->hasBondWith(neighbour1))
        {
            LateralSpec *specie1 = neighbour1->specByRole<Dimer>(18);
            if (specie1)
            {
                eachNeighbour(atoms1[0], &Diamond::cross_100, [&](Atom *neighbour2) {
                    if (neighbour2->is(18))
                    {
                        LateralSpec *specie2 = neighbour2->specByRole<Dimer>(18);
                        if (specie2 == specie1)
                        {
                            chunks[index++] = new ForwardMethylIncorporationMiEdgeLateral(this, specie1);
                        }
                    }
                });
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
