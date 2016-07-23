require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        describe OthersideNode, type: :algorithm do
          include_context :lateral_node_context

          let(:typical_reaction) { dept_dimer_formation }
          let(:lateral_reaction) { dept_end_lateral_df }

          subject { lateral_factory.otherside_node(node) }
          let(:spec_atom) { [lateral_dimer, lateral_dimer.atom(:cr)] }
          let(:lateral_dimer) do
            lateral_chunks.sidepiece_specs.select { |spec| spec.name == :dimer }.first
          end

          describe '#uniq_specie' do
            it { expect(subject.uniq_specie).to eq(subject.uniq_specie) }
            it { expect(subject.uniq_specie).not_to eq(node.uniq_specie) }
            it { expect(subject.original.uniq_specie).to eq(node.uniq_specie) }
          end

          describe '#spec_atom' do
            it { expect(subject.spec_atom).to eq(node.spec_atom) }
          end

          describe '#lateral_reaction' do
            let(:name) { 'ForwardDimerFormationEndLateral' }
            it { expect(subject.lateral_reaction.class_name).to eq(name) }
          end

          describe '#side?' do
            it { expect(subject.side?).to be_truthy }
          end
        end

      end
    end
  end
end
