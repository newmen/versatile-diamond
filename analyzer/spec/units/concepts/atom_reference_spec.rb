require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomReference do
      let(:ref) { described_class.new(ethylene_base, :c1) }

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
        it { expect(c1.same?(ref)).to be_true }
        it { expect(ref.same?(c1)).to be_true }
        it { expect(ref.same?(ref.dup)).to be_true }
      end

      describe '#original_same?' do
        it { expect(c1.original_same?(ref)).to be_true }
        it { expect(ref.original_same?(c1)).to be_true }
      end

      describe '#actives' do
        it { expect(ref.actives).to eq(0) }
      end

      describe '#monovalents' do
        it { expect(ref.monovalents).to be_empty }
      end

      describe '#incoherent? and #unfixed?' do
        it { expect(ref.incoherent?).to be_false }
        it { expect(ref.unfixed?).to be_false }
      end

      describe '#diff' do
        it { expect(ref.diff(ref.dup)).to be_empty }
        it { expect(ref.diff(c)).to be_empty }
        it { expect(ref.diff(activated_c)).to be_empty }
        it { expect(ref.diff(unfixed_c)).to eq([:unfixed]) }
        it { expect(ref.diff(unfixed_activated_c)).to eq([:unfixed]) }

        it { expect(AtomReference.new(bridge_base, :ct).
          diff(activated_incoherent_cd)).to eq([:incoherent]) }
        it { expect(AtomReference.new(bridge_base, :ct).
          diff(incoherent_cd)).to eq([:incoherent]) }
      end

      describe '#relations_in' do
        it { expect(bridge.atom(:cr).relations_in(bridge).size).to eq(4) }
      end

      describe '#additional_relations' do
        it { expect(bridge.atom(:cr).additional_relations.size).to eq(2) }
      end

      describe '#reference_to?' do
        it { expect(ref.reference_to?(ethylene_base)).to be_true }
        it { expect(ref.reference_to?(bridge_base)).to be_false }
      end

      describe '#update_keyname' do
        let(:spec) { activated_methyl_on_incoherent_bridge }
        subject { described_class.new(spec, :cb) }
        before do
          subject # instantize subject before
          spec.replace_base_spec(bridge_base_dup)
          subject.update_keyname
        end

        it { expect(subject.keyname).to eq(:t) }
      end

      it_behaves_like '#lattice' do
        let(:target) { c1 }
        let(:reference) { ref }
      end
    end

  end
end
