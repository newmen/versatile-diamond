require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Atom do
      describe '#self.hydrogen?' do
        it { expect(Atom.hydrogen?(h)).to be_true }
        it { expect(Atom.hydrogen?(c)).to be_false }
      end

      describe '#valence' do
        it { expect(h.valence).to eq(1) }
        it { expect(c.valence).to eq(4) }
      end

      describe '#original_valence' do
        it { expect(h.original_valence).to eq(1) }
        it { expect(c.original_valence).to eq(4) }
      end

      describe '#lattice' do
        it 'set and get lattice' do
          expect(cd.lattice).to eq(diamond)
        end
      end

      describe '#reference?' do
        it { expect(c.reference?).to be_false }
      end

      describe '#specific?' do
        it { expect(c.specific?).to be_false }
      end

      describe '#same?' do
        it { expect(c.same?(h)).to be_false }
        it { expect(c.same?(c.dup)).to be_true }
        it { expect(c.same?(cd)).to be_false }
        it { expect(cd.same?(cd.dup)).to be_true  }
      end

      describe '#original_same?' do
        it { expect(c.original_same?(n)).to be_false }
        it { expect(c.original_same?(cd)).to be_false }

        let(:other) { c.dup }
        it { expect(c.original_same?(other)).to be_true }
        it { expect(other.original_same?(c)).to be_true }
      end

      describe '#actives' do
        it { expect(h.actives).to eq(0) }
        it { expect(c.actives).to eq(0) }
      end

      describe '#monovalents' do
        it { expect(c.monovalents).to be_empty }
      end

      describe '#incoherent? and #unfixed?' do
        it { expect(c.incoherent?).to be_false }
        it { expect(c.unfixed?).to be_false }
      end

      describe '#diff' do
        it { expect(c.diff(c.dup)).to be_empty }
        it { expect(c.diff(unfixed_c)).to eq([:unfixed]) }
        it { expect(c.diff(unfixed_activated_c)).to eq([:unfixed]) }
        it { expect(cd.diff(incoherent_cd)).to eq([:incoherent]) }
        it { expect(cd.diff(activated_incoherent_cd)).to eq([:incoherent]) }
      end

      describe '#relevants' do
        it { expect(cd.relevants).to be_empty }
      end

      describe '#relations_in' do
        it { expect(cd.relations_in(bridge)).to eq(bridge.links[cd]) }
        it { expect(cd.relations_in(bridge).object_id).
          not_to eq(bridge.links[cd].object_id) }

        it { expect(cd.relations_in(bridge).size).to eq(2) }
      end

      describe '#additional_relations' do
        it { expect(cd.additional_relations).to be_empty }
      end

      describe '#closed' do
        subject { cd.closed }
        it { should_not eq(cd) }
        it { expect(subject.name).to eq(:C) }
        it { expect(subject.valence).to eq(4) }
      end
    end

  end
end
