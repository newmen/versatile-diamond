require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe SidepieceNode, type: :algorithm do
          include_context :lateral_node_context

          let(:typical_reaction) { dept_symmetric_dimer_formation }
          let(:lateral_reaction) { dept_small_ab_lateral_sdf }

          let(:sidepiece_specs) { lateral_chunks.sidepiece_specs }

          subject { lateral_factory.sidepiece_node(node) }
          let(:spec_atom) { [cross_bridge, cross_bridge.atom(:ct)] }
          let(:cross_bridge) { lateral_chunks.sidepiece_specs.to_a.first }

          let(:other) { lateral_factory.sidepiece_node(same_different_node) }
          let(:same_different_node) { reaction_factory.get_node(front_spec_atom) }
          let(:front_spec_atom) { [front_bridge, front_bridge.atom(:ct)] }
          let(:front_bridge) { (sidepiece_specs.to_a - [cross_bridge]).first }

          shared_context :bridge_with_dimer_sides do
            let(:typical_reaction) { dept_dimer_formation }
            let(:lateral_reaction) { dept_ewb_lateral_df }

            let(:cross_bridge) do
              sidepiece_specs.select { |spec| spec.name == :bridge }.first
            end
            let(:front_dimer) do
              sidepiece_specs.select { |spec| spec.name == :dimer }.first
            end

            let(:front_spec_atom) { [front_dimer, front_dimer.atom(:cr)] }
            let(:edge_spec_atom) { [front_dimer, front_dimer.atom(:cl)] }
            let(:edge_node) { reaction_factory.get_node(edge_spec_atom) }
            let(:different) { lateral_factory.sidepiece_node(edge_node) }
          end

          describe '#uniq_specie' do
            it 'species are same' do
              expect(subject.uniq_specie).to eq(node.uniq_specie)
              expect(subject.uniq_specie).to eq(other.uniq_specie)
            end

            describe 'different sidepieces' do
              include_context :bridge_with_dimer_sides
              it 'not all species are same' do
                expect(subject.uniq_specie).to eq(node.uniq_specie)

                expect(other.uniq_specie).to eq(same_different_node.uniq_specie)
                expect(other.uniq_specie).to eq(different.uniq_specie)
                expect(subject.uniq_specie).not_to eq(other.uniq_specie)
              end
            end
          end

          describe '#spec_atom' do
            it 'spec-atom pairs are same' do
              expect(subject.spec_atom).to eq(spec_atom)
              expect(other.spec_atom).to eq(front_spec_atom)

              expect(subject.spec_atom).not_to eq(other.spec_atom)
              expect(subject.original.spec_atom).to eq(other.original.spec_atom)
            end

            describe 'different sidepieces' do
              include_context :bridge_with_dimer_sides
              it 'spec-atom pairs are different' do
                expect(subject.spec_atom).to eq(spec_atom)
                expect(other.spec_atom).to eq(front_spec_atom)
                expect(different.spec_atom).to eq(edge_spec_atom)

                expect(subject.spec_atom).not_to eq(other.spec_atom)
                expect(subject.spec_atom).not_to eq(different.spec_atom)
                expect(other.spec_atom).not_to eq(different.spec_atom)

                expect(subject.original.spec_atom).not_to eq(other.original.spec_atom)
                expect(other.original.spec_atom).not_to eq(different.original.spec_atom)
              end
            end
          end

          describe '#lateral_reaction' do
            describe 'many activated bridges' do
              let(:cross_name) do
                'CombinedForwardSymmetricDimerFormationWith100CrossBridgeCTs'
              end
              it { expect(subject.lateral_reaction.class_name).to eq(cross_name) }

              let(:front_name) do
                'CombinedForwardSymmetricDimerFormationWith100FrontBridgeCTs'
              end
              it { expect(other.lateral_reaction.class_name).to eq(front_name) }
            end

            describe 'different sidepieces' do
              include_context :bridge_with_dimer_sides
              let(:cross_name) { 'CombinedForwardDimerFormationWith100FrontBridge' }
              it { expect(subject.lateral_reaction.class_name).to eq(cross_name) }

              let(:front_name) { 'CombinedForwardDimerFormationWith100CrossDimer' }
              it { expect(other.lateral_reaction.class_name).to eq(front_name) }
              it { expect(different.lateral_reaction.class_name).to eq(front_name) }
            end
          end

          describe '#side?' do
            it { expect(subject.side?).to be_falsey }
          end
        end

      end
    end
  end
end
