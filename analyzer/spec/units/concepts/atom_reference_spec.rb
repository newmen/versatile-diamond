require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomReference do
      let(:ref) { described_class.new(ethylene_base, :c1) }
      let(:specific_ref) { described_class.new(methyl_on_incoherent_bridge, :cb) }

      describe '#dup' do
        subject { ref.dup }
        it { expect(subject).not_to eq(ref) }
        it { expect(subject.spec).to eq(ref.spec) }
        it { expect(subject.keyname).to eq(ref.keyname) }
      end

      describe '#name' do
        it { expect(ref.name).to eq(:C) }
      end

      describe '#valence' do
        it { expect(ref.valence).to eq(2) }
      end

      describe '#original_valence' do
        it { expect(ref.original_valence).to eq(4) }
      end

      describe '#same?' do
        it { expect(c1.same?(ref)).to be_truthy }
        it { expect(ref.same?(c1)).to be_truthy }
        it { expect(ref.same?(ref.dup)).to be_truthy }
      end

      describe '#original_same?' do
        it { expect(c1.original_same?(ref)).to be_truthy }
        it { expect(ref.original_same?(c1)).to be_truthy }
      end

      describe '#actives' do
        it { expect(ref.actives).to eq(0) }
      end

      describe '#monovalents' do
        it { expect(ref.monovalents).to be_empty }
      end

      describe '#incoherent? and #unfixed?' do
        it { expect(ref.incoherent?).to be_falsey }
        it { expect(ref.unfixed?).to be_falsey }
      end

      describe '#diff' do
        it { expect(ref.diff(ref.dup)).to be_empty }
        it { expect(ref.diff(c)).to be_empty }
        it { expect(ref.diff(activated_c)).to be_empty }
        it { expect(ref.diff(unfixed_c)).to eq([unfixed]) }
        it { expect(ref.diff(unfixed_activated_c)).to eq([unfixed]) }

        it { expect(AtomReference.new(bridge_base, :ct).
          diff(activated_incoherent_cd)).to eq([incoherent]) }
        it { expect(AtomReference.new(bridge_base, :ct).
          diff(incoherent_cd)).to eq([incoherent]) }
      end

      describe '#relevants' do
        it { expect(bridge.atom(:cr).relevants).to be_empty }
        it { expect(specific_ref.relevants).to eq([incoherent]) }
      end

      describe '#reference?' do
        it { expect(bridge.atom(:cr).reference?).to be_truthy }
      end

      describe '#specific?' do
        it { expect(bridge.atom(:cr).specific?).to be_falsey }
        it { expect(specific_ref.specific?).to be_truthy }
      end

      describe '#additional_relations' do
        it { expect(bridge.atom(:cr).additional_relations.size).to eq(2) }
      end

      it_behaves_like '#lattice' do
        let(:target) { c1 }
        let(:reference) { ref }
      end
    end

  end
end
