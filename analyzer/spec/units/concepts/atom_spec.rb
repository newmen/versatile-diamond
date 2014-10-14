require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Atom do
      describe '#self.hydrogen' do
        it { expect(Atom.hydrogen).to be_a(Atom) }
        it { expect(Atom.hydrogen.name).to eq(:H) }
        it { expect(Atom.hydrogen.valence).to eq(1) }
      end

      describe '#self.hydrogen?' do
        it { expect(Atom.hydrogen?(h)).to be_truthy }
        it { expect(Atom.hydrogen?(c)).to be_falsey }
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
        it { expect(c.lattice).to be_nil }
        it { expect(cd.lattice).to eq(diamond) }
      end

      describe '#reference?' do
        it { expect(c.reference?).to be_falsey }
      end

      describe '#specific?' do
        it { expect(c.specific?).to be_falsey }
      end

      describe '#same?' do
        it { expect(c.same?(h)).to be_falsey }
        it { expect(c.same?(c.dup)).to be_truthy }
        it { expect(c.same?(cd)).to be_falsey }
        it { expect(cd.same?(cd.dup)).to be_truthy  }
      end

      describe '#original_same?' do
        it { expect(c.original_same?(n)).to be_falsey }
        it { expect(c.original_same?(cd)).to be_falsey }

        let(:other) { c.dup }
        it { expect(c.original_same?(other)).to be_truthy }
        it { expect(other.original_same?(c)).to be_truthy }
      end

      describe '#actives' do
        it { expect(h.actives).to eq(0) }
        it { expect(c.actives).to eq(0) }
      end

      describe '#monovalents' do
        it { expect(c.monovalents).to be_empty }
      end

      describe '#incoherent? and #unfixed?' do
        it { expect(c.incoherent?).to be_falsey }
        it { expect(c.unfixed?).to be_falsey }
      end

      describe '#diff' do
        it { expect(c.diff(c.dup)).to be_empty }
        it { expect(c.diff(unfixed_c)).to eq([unfixed]) }
        it { expect(c.diff(unfixed_activated_c)).to eq([unfixed]) }
        it { expect(cd.diff(incoherent_cd)).to eq([incoherent]) }
        it { expect(cd.diff(activated_incoherent_cd)).to eq([incoherent]) }
      end

      describe '#relevants' do
        it { expect(cd.relevants).to be_empty }
      end

      describe '#additional_relations' do
        it { expect(cd.additional_relations).to be_empty }
      end

      describe '#relations_limits' do
        let(:diamond_relations_limits) do
          {
            param_amorph => 1,
            param_100_front => 2,
            param_100_cross => 2,
            param_110_front => 2,
            param_110_cross => 2,
          }
        end
        it { expect(cd.relations_limits).to eq(diamond_relations_limits) }
        it { expect(c.relations_limits).to eq({ param_amorph => 4 }) }
        it { expect(n.relations_limits).to eq({ param_amorph => 3 }) }
      end

      describe '#to_s' do
        it { expect(c.to_s).to eq('C') }
        it { expect(cd.to_s).to eq('C%d') }
      end
    end

  end
end
