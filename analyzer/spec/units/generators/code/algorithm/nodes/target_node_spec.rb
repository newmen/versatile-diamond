require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe TargetNode, type: :algorithm do
          include_context :lateral_node_context

          let(:typical_reaction) { dept_dimer_formation }
          let(:lateral_reaction) { dept_end_lateral_df }

          subject { lateral_factory.target_node(node) }
          let(:spec_atom) { [activated_bridge, activated_bridge.atom(:ct)] }

          describe '#uniq_specie' do
            it { expect(subject.uniq_specie).to eq(node.uniq_specie) }
          end

          describe '#spec_atom' do
            it { expect(subject.spec_atom).to eq(node.spec_atom) }
          end

          describe '#lateral_reaction' do
            it { expect { subject.lateral_reaction }.to raise_error }
          end

          describe '#side?' do
            it { expect(subject.side?).to be_falsey }
          end
        end

      end
    end
  end
end
