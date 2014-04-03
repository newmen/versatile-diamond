require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificAtom do
      subject { described_class.new(n) }

      describe '#initialize' do
        subject do
          described_class.new(cd,
            options: [:active, :incoherent], monovalents: [:H])
        end
        it { expect(subject.actives).to eq(1) }
        it { expect(subject.incoherent?).to be_true }
        it { expect(subject.monovalents).to eq([:H]) }

        describe 'from specific atom' do
          let(:child) { described_class.new(cd, ancestor: subject) }
          it { expect(child.actives).to eq(1) }
          it { expect(child.incoherent?).to be_true }
          it { expect(child.monovalents).to eq([:H]) }
        end
      end

      describe '#dup' do
        it { expect(subject.dup).not_to eq(subject) }
        it { expect(activated_c.dup.actives).to eq(1) }
        it { expect(activated_cd.dup.lattice).to eq(diamond) }
        it { expect(activated_cd_hydride.dup.monovalents).to eq([:H]) }
      end

      describe '#name' do
        it { expect(activated_n.name).to eq(:N) }
        it { expect(activated_c.name).to eq(:C) }
      end

      describe '#valence' do
        it { expect(activated_n.valence).to eq(2) }
        it { expect(activated_c.valence).to eq(3) }
        it { expect(extra_activated_cd.valence).to eq(2) }
        it { expect(SpecificAtom.new(c).valence).to eq(4) }
      end

      describe '#original_valence' do
        it { expect(activated_n.original_valence).to eq(3) }
        it { expect(activated_c.original_valence).to eq(4) }
        it { expect(extra_activated_cd.original_valence).to eq(4) }
        it { expect(SpecificAtom.new(c).original_valence).to eq(4) }
      end

      describe '#actives' do
        it { expect(subject.actives).to eq(0) }

        it { expect(activated_h.actives).to eq(1) }
        it { expect(activated_c.actives).to eq(1) }
        it { expect(activated_cd.actives).to eq(1) }
        it { expect(extra_activated_cd.actives).to eq(2) }
      end

      %w(incoherent unfixed).each do |state|
        describe "##{state}!?" do
          describe 'is set' do
            before { subject.send("#{state}!") }
            it { expect(subject.send("#{state}?")).to be_true }

            describe 'already stated' do
              it { expect { subject.send("#{state}!") }.
                to raise_error SpecificAtom::AlreadyStated }
            end

            describe 'reset state' do
              before { subject.send("not_#{state}!") }
              it { expect(subject.send("#{state}?")).to be_false }
            end
          end

          describe 'is not set' do
            it { expect(subject.send("#{state}?")).to be_false }
            it { expect { subject.send("not_#{state}!") }.
              to raise_error SpecificAtom::NotStated }
          end
        end
      end

      describe '#monovalents' do
        it { expect(activated_c.monovalents).to be_empty }
        it { expect(cd_chloride.monovalents).to eq([:Cl]) }
        it { expect(activated_cd_hydride.monovalents).to eq([:H]) }
        it { expect(cd_extra_hydride.monovalents).to eq([:H, :H]) }
      end

      describe '#same?' do
        it { expect(subject.same?(n)).to be_false }
        it { expect(n.same?(subject)).to be_false }

        describe 'same class instance' do
          let(:other) { SpecificAtom.new(n.dup) }

          shared_examples_for 'equal if both and not if just one' do
            it 'both atoms' do
              do_with(subject)
              do_with(other)
              expect(subject.same?(other)).to be_true
            end

            it 'just one atom' do
              do_with(other)
              expect(subject.same?(other)).to be_false
            end
          end

          it_behaves_like 'equal if both and not if just one' do
            def do_with(atom); atom.active! end
          end

          it_behaves_like 'equal if both and not if just one' do
            def do_with(atom); atom.incoherent! end
          end

          it_behaves_like 'equal if both and not if just one' do
            def do_with(atom); atom.unfixed! end
          end

          it_behaves_like 'equal if both and not if just one' do
            def do_with(atom); atom.use!(h) end
          end
        end
      end

      describe '#diff' do
        it { expect(unfixed_c.diff(c)).to be_empty }
        it { expect(unfixed_activated_c.diff(c)).to be_empty }
        it { expect(unfixed_c.diff(SpecificAtom.new(c))).to be_empty }

        it { expect(incoherent_cd.diff(cd)).to be_empty }
        it { expect(activated_incoherent_cd.diff(cd)).to be_empty }
        it { expect(activated_incoherent_cd.diff(activated_cd)).to be_empty }
        it { expect(activated_incoherent_cd.diff(bridge.atom(:cr))).
          to be_empty }
        it { expect(activated_cd.diff(bridge.atom(:cr))).to be_empty }

        it { expect(activated_c.diff(unfixed_c)).to eq([:unfixed]) }
        it { expect(activated_c.diff(unfixed_activated_c)).to eq([:unfixed]) }
        it { expect(activated_cd.diff(incoherent_cd)).to eq([:incoherent]) }
        it { expect(activated_cd.diff(activated_incoherent_cd)).
          to eq([:incoherent]) }
      end

      describe '#apply_diff' do
        before(:each) { activated_c.apply_diff([:unfixed, :incoherent]) }
        it { expect(activated_c.incoherent?).to be_true }
        it { expect(activated_c.unfixed?).to be_true }
      end

      describe '#relevants' do
        it { expect(activated_c.relevants).to be_empty }
        it { expect(unfixed_c.relevants).to eq([:unfixed]) }
        it { expect(unfixed_activated_c.relevants).to eq([:unfixed]) }
        it { expect(incoherent_cd.relevants).to eq([:incoherent]) }
        it { expect(activated_incoherent_cd.relevants).to eq([:incoherent]) }
      end

      it_behaves_like '#lattice' do
        let(:target) { n }
        let(:reference) { subject }
      end

      describe '#relations_in' do
        let(:spec) { activated_bridge }

        describe ':ct of activated_bridge' do
          subject { spec.atom(:ct) }
          it { expect(subject.relations_in(spec)).to match_array([
              :active,
              [spec.atom(:cr), bond_110_cross],
              [spec.atom(:cl), bond_110_cross]
            ]) }
        end

        describe ':cr of activated_bridge' do
          subject { spec.atom(:cr) }
          it { expect(subject.relations_in(spec).map(&:last)).to match_array([
              bond_110_front,
              bond_110_cross,
              bond_110_cross,
              position_100_front
            ]) }
        end

        describe ':ct of activated_hydrogenated_bridge' do
          let(:spec) { activated_hydrogenated_bridge }
          subject { spec.atom(:ct) }
          it { expect(subject.relations_in(spec)).to match_array([
              :H,
              :active,
              [spec.atom(:cr), bond_110_cross],
              [spec.atom(:cl), bond_110_cross]
            ]) }
        end
      end

      describe '#size' do
        it { expect(activated_cd.size.round(2)).to eq(0.34) }
        it { expect(activated_cd_hydride.size.round(2)).to eq(0.68) }
        it { expect(activated_incoherent_cd.size.round(2)).to eq(0.47) }
        it { expect(incoherent_cd.size.round(2)).to eq(0.13) }
        it { expect(incoherent_cd_hydride.size.round(2)).to eq(0.47) }
        it { expect(unfixed_activated_c.size.round(2)).to eq(0.47) }
        it { expect(cd_chloride.size.round(2)).to eq(0.34) }
      end

      describe '#to_s' do
        it { expect(activated_c.to_s).to eq('C[*]') }
        it { expect(unfixed_activated_c.to_s).to eq('C[*, u]') }
        it { expect(c_hydride.to_s).to eq('C[H]') }

        it { expect(activated_cd.to_s).to eq('C%d[*]') }
        it { expect(incoherent_cd.to_s).to eq('C%d[i]') }
        it { expect(cd_hydride.to_s).to eq('C%d[H]') }
        it { expect(cd_chloride.to_s).to eq('C%d[Cl]') }
        it { expect(activated_cd_hydride.to_s).to eq('C%d[*, H]') }
        it { expect(activated_incoherent_cd.to_s).to eq('C%d[*, i]') }
        it { expect(incoherent_cd_hydride.to_s).to eq('C%d[H, i]') }
      end
    end

  end
end
