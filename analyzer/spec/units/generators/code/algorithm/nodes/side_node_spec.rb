require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe SideNode, type: :algorithm do
          let(:generator) do
            stub_generator(
              specific_specs: [dept_activated_bridge],
              typical_reactions: [dept_dimer_formation])
          end

          let(:factory) { Algorithm::ReactionNodesFactory.new(generator) }
          let(:spec_atom) { [activated_bridge, activated_bridge.atom(:ct)] }
          let(:node) { factory.get_node(spec_atom) }
          subject { described_class.new(node) }

          describe '#uniq_specie' do
            it { expect(subject.uniq_specie).to eq(subject.uniq_specie) }
            it { expect(subject.uniq_specie).not_to eq(node.uniq_specie) }
            it { expect(subject.original.uniq_specie).to eq(node.uniq_specie) }
          end

          describe '#spec_atom' do
            it { expect(subject.spec_atom).to eq(node.spec_atom) }
          end

          describe '#side?' do
            it { expect(subject.side?).to be_truthy }
          end
        end

      end
    end
  end
end
