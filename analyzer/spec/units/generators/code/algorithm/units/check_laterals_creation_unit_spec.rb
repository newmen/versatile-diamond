require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe CheckLateralsCreationUnit, type: :algorithm, use: :chunks do
          include_context :check_laterals_context

          subject { described_class.new(dict, context, lateral_chunks) }
          let(:context) do
            LateralContextProvider.new(dict, backbone.big_graph, ordered_graph)
          end

          describe '#create' do
            before do
              dict.make_specie_s(target_species)
              side_opts = { type: Expressions::ReactantSpecieType[] }
              dict.make_specie_s(sidepiece_species, **side_opts)
            end

            describe 'side dimer' do
              include_context :end_dimer_formation_lateral_context
              let(:spec) { lateral_dimer }
              let(:code) do
                <<-CODE
ChainFactory<
    DuoLateralFactory,
    ForwardDimerFormationEndLateral,
    ForwardDimerFormation
> factory(dimer1, species1);
factory.checkoutReactions<ForwardDimerFormationEndLateral>();
                CODE
              end
              it { expect(subject.create.code).to eq(code.rstrip) }
            end

            describe 'side bridge' do
              include_context :small_activated_bridges_lateral_context
              let(:spec) { front_bridge }
              let(:code) do
                <<-CODE
ChainFactory<
    UnoLateralFactory,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTs,
    ForwardSymmetricDimerFormation
> factory(bridgeCTs1, bridgeCTs2);
factory.checkoutReactions<
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTs,
    ForwardSymmetricDimerFormationSmall,
    CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTsAnd100FrontBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs,
    CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTsAnd100CrossBridgeCTsAnd100CrossBridgeCTsAnd100FrontBridgeCTsAnd100FrontBridgeCTs
>();
                CODE
              end
              it { expect(subject.create.code).to eq(code.rstrip) }
            end
          end
        end

      end
    end
  end
end
