require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentBaseSpec do
      def wrap(spec)
        described_class.new(spec)
      end

      it_behaves_like :minuend do
        subject { wrap(bridge_base) }
      end

      describe '#same?' do
        describe 'bridge_base' do
          let(:same_bridge) { wrap(bridge_base_dup) }
          subject { wrap(bridge_base) }

          it { expect(subject.same?(same_bridge)).to be_true }
          it { expect(same_bridge.same?(subject)).to be_true }

          it { expect(subject.same?(wrap(dimer_base))).to be_false }
        end

        describe 'methyl_on_bridge_base' do
          let(:other) { wrap(high_bridge_base) }
          subject { wrap(methyl_on_bridge_base) }

          it { expect(subject.same?(other)).to be_false }
          it { expect(other.same?(subject)).to be_false }
        end
      end

      describe '#residual' do
        subject { wrap(methyl_on_bridge_base)- wrap(bridge_base) }
        it { should be_a(SpecResidual) }
        it { expect(subject.links_size).to eq(2) }

        it_behaves_like :swap_to_atom_reference do
          let(:atoms_num) { 1 }
          let(:refs_num) { 1 }
        end
      end

      describe '#organize_dependencies!' do
        let(:specs) do
          [
            bridge_base,
            dimer_base,
            high_bridge_base,
            methyl_on_bridge_base,
            methyl_on_dimer_base,
            extended_bridge_base,
            extended_dimer_base,
            methyl_on_extended_bridge_base,
          ]
        end

        let(:wrapped_specs) { specs.map { |spec| wrap(spec) } }
        let(:cache) { Hash[wrapped_specs.map(&:name).zip(wrapped_specs)] }
        let(:table) { BaseSpeciesTable.new(wrapped_specs) }

        describe 'bridge' do
          subject { cache[:bridge] }
          before { subject.organize_dependencies!(table) }

          describe '#rest' do
            it { expect(subject.rest).to be_nil }
          end

          describe '#parents' do
            it { expect(subject.parents).to be_empty }
          end
        end

        describe 'methyl_on_bridge' do
          subject { cache[:methyl_on_bridge] }
          before { subject.organize_dependencies!(table) }

          describe '#rest' do
            it { expect(subject.rest.links_size).to eq(2) }
          end

          describe '#parents' do
            it { expect(subject.parents).to eq([cache[:bridge]]) }
          end
        end
      end

      # describe '#remove_child' do
      #   pending 'deprecated'
      #   # before do
      #   #   dimer_base.store_child(dimer)
      #   #   dimer_base.remove_child(dimer)
      #   # end
      #   # it { expect(dimer_base.childs).to be_empty }
      # end
    end

  end
end
