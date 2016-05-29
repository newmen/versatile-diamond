require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe LateralReactionSelectBuilder, type: :algorithm do
          let(:generator) do
            stub_generator(
              base_specs: respond_to?(:base_specs) ? base_specs : [],
              specific_specs: respond_to?(:specific_specs) ? specific_specs : [],
              typical_reactions: [typical_reaction],
              lateral_reactions: lateral_reactions
            )
          end

          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:lateral_chunks) { reaction.lateral_chunks }
          let(:builder) { described_class.new(generator, lateral_chunks) }

          shared_examples_for :check_select_code do
            it { expect(builder.build).to eq(select_algorithm) }
          end

          describe '#build' do
            it_behaves_like :check_select_code do
              let(:typical_reaction) { dept_dimer_formation }
              let(:lateral_reactions) { [dept_end_lateral_df, dept_middle_lateral_df] }
              let(:select_algorithm) do
                <<-CODE
    if (num == 1)
    {
        return chunks[0];
    }
    else if (num == 2)
    {
        return new ForwardDimerFormationMiddleLateral(chunks);
    }
    assert(false);
    return nullptr;
                CODE
              end
            end

            it_behaves_like :check_select_code do
              let(:typical_reaction) { dept_incoherent_dimer_drop }
              let(:lateral_reactions) { [dept_end_lateral_idd] }
              let(:select_algorithm) do
                <<-CODE
    if (num == 1)
    {
        return chunks[0];
    }
    else if (num == 2)
    {
        return new CombinedForwardIncoherentDimerDropWith100CrossDimerAnd100CrossDimer(chunks);
    }
    assert(false);
    return nullptr;
                CODE
              end
            end

            it_behaves_like :check_select_code do
              let(:typical_reaction) { dept_symmetric_dimer_formation }
              let(:lateral_reactions) do
                [dept_small_ab_lateral_sdf, dept_big_ab_lateral_sdf]
              end
              let(:select_algorithm) do
                <<-CODE
    if (num == 1)
    {
        return chunks[0];
    }
    else if (num == 6)
    {
        return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs(chunks);
    }
    else
    {
        std::unordered_map<ushort, ushort> counter = countReactions(chunks, num);
        if (num == 2)
        {
            if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 2)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTs(chunks);
            }
            else if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 1 && counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 1)
            {
                return new ForwardSymmetricDimerFormationSmall(chunks);
            }
            else if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 2)
            {
                return new CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTsAnd100FrontBridgeCTs(chunks);
            }
        }
        else if (num == 3)
        {
            if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 3)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTs(chunks);
            }
            else if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 2 && counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 1)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs(chunks);
            }
            else if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 1 && counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 2)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs(chunks);
            }
        }
        else if (num == 4)
        {
            if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 4)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTs(chunks);
            }
            else if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 3 && counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 1)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs(chunks);
            }
            else if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 2 && counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 2)
            {
                return new ForwardSymmetricDimerFormationBig(chunks);
            }
        }
        else if (num == 5)
        {
            if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 4 && counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 1)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs(chunks);
            }
            else if (counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_CROSS_BRIDGE_C_TS] == 3 && counter[COMBINED_FORWARD_SYMMETRIC_DIMER_FORMATION_WITH_100_FRONT_BRIDGE_C_TS] == 2)
            {
                return new CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs(chunks);
            }
        }
    }
    assert(false);
    return nullptr;
                CODE
              end
            end
          end
        end

      end
    end
  end
end
