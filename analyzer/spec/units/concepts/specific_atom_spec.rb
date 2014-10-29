require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificAtom do
      subject { described_class.new(n) }

      describe '#initialize' do
        subject do
          described_class.new(cd,
            options: [active_bond, incoherent], monovalents: [adsorbed_h])
        end

        it { expect(subject.actives).to eq(1) }
        it { expect(subject.incoherent?).to be_truthy }
        it { expect(subject.monovalents).to eq([adsorbed_h]) }

        describe 'from specific atom' do
          let(:child) { described_class.new(cd, ancestor: subject) }
          it { expect(child.actives).to eq(1) }
          it { expect(child.incoherent?).to be_truthy }
          it { expect(child.monovalents).to eq([adsorbed_h]) }
        end
      end

      describe '#dup' do
        it { expect(subject.dup).not_to eq(subject) }
        it { expect(activated_c.dup.actives).to eq(1) }
        it { expect(activated_cd.dup.lattice).to eq(diamond) }
        it { expect(activated_cd_hydride.dup.monovalents).to eq([adsorbed_h]) }
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
            it { expect(subject.send("#{state}?")).to be_truthy }

            describe 'already stated' do
              it { expect { subject.send("#{state}!") }.
                to raise_error SpecificAtom::AlreadyStated }
            end

            describe 'reset state' do
              before { subject.send("not_#{state}!") }
              it { expect(subject.send("#{state}?")).to be_falsey }
            end
          end

          describe 'is not set' do
            it { expect(subject.send("#{state}?")).to be_falsey }
            it { expect { subject.send("not_#{state}!") }.
              to raise_error SpecificAtom::NotStated }
          end
        end
      end

      describe '#monovalents' do
        it { expect(activated_c.monovalents).to be_empty }
        it { expect(cd_chloride.monovalents).to eq([adsorbed_cl]) }
        it { expect(activated_cd_hydride.monovalents).to eq([adsorbed_h]) }
        it { expect(cd_extra_hydride.monovalents).to eq([adsorbed_h] * 2) }
      end

      describe '#reference?' do
        it { expect(activated_cd.reference?).to be_falsey }

        let(:ref) { described_class.new(bridge.atom(:cr)) }
        it { expect(ref.reference?).to be_truthy }
      end

      describe '#relations_limits' do
        it { expect(activated_c.relations_limits).to eq(c.relations_limits) }
        it { expect(activated_cd.relations_limits).to eq(cd.relations_limits) }
      end

      describe '#specific?' do
        it { expect(activated_c.specific?).to be_truthy }
        it { expect(cd_chloride.specific?).to be_truthy }
        it { expect(incoherent_cd.specific?).to be_truthy }

        it { expect(described_class.new(cd).specific?).to be_falsey }
      end

      describe '#same?' do
        it { expect(subject.same?(n)).to be_truthy }
        it { expect(n.same?(subject)).to be_truthy }

        describe 'same class instance' do
          let(:other) { SpecificAtom.new(n.dup) }

          shared_examples_for 'equal if both and not if just one' do
            it 'both atoms' do
              do_with(subject)
              do_with(other)
              expect(subject.same?(other)).to be_truthy
            end

            it 'just one atom' do
              do_with(other)
              expect(subject.same?(other)).to be_falsey
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

      describe '#original_same?' do
        it { expect(subject.original_same?(SpecificAtom.new(c))).to be_falsey }

        let(:other) { subject.dup }
        before { other.active! }
        it { expect(subject.original_same?(other)).to be_truthy }
        it { expect(other.original_same?(subject)).to be_truthy }
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

        it { expect(activated_c.diff(unfixed_c)).to eq([unfixed]) }
        it { expect(activated_c.diff(unfixed_activated_c)).to eq([unfixed]) }
        it { expect(activated_cd.diff(incoherent_cd)).to eq([incoherent]) }
        it { expect(activated_cd.diff(activated_incoherent_cd)).
          to eq([incoherent]) }
      end

      describe '#apply_diff' do
        before(:each) { activated_c.apply_diff([unfixed]) }
        it { expect(activated_c.incoherent?).to be_falsey }
        it { expect(activated_c.unfixed?).to be_truthy }
      end

      describe '#relevants' do
        it { expect(activated_c.relevants).to be_empty }
        it { expect(unfixed_c.relevants).to eq([unfixed]) }
        it { expect(unfixed_activated_c.relevants).to eq([unfixed]) }
        it { expect(incoherent_cd.relevants).to eq([incoherent]) }
        it { expect(activated_incoherent_cd.relevants).to eq([incoherent]) }

        describe 'chain of relevants' do
          let(:ref) { AtomReference.new(unfixed_methyl_on_bridge, :cm) }

          subject { described_class.new(ref) }
          before { subject.incoherent! }

          it { expect(subject.relevants).to match_array([incoherent, unfixed]) }
        end
      end

      it_behaves_like '#lattice' do
        let(:target) { n }
        let(:reference) { subject }
      end

      describe '#additional_relations' do
        let(:spec) { activated_bridge }

        describe ':ct of activated_bridge' do
          subject { spec.atom(:ct) }
          it { expect(subject.additional_relations).to eq([[subject, active_bond]]) }
        end

        describe ':cr of activated_bridge' do
          subject { spec.atom(:cr) }
          it { expect(subject.additional_relations.map(&:last)).to match_array([
              bond_110_cross,
              bond_110_cross,
            ]) }
        end

        describe ':cr of right_activated_bridge' do
          subject { spec.atom(:cr) }
          let(:spec) { right_activated_bridge }
          let(:relations) { subject.additional_relations.map(&:last) }

          it { expect(relations).to match_array([
              active_bond,
              bond_110_cross,
              bond_110_cross,
            ]) }
        end

        describe ':ct of activated_hydrogenated_bridge' do
          let(:spec) { activated_hydrogenated_bridge }
          subject { spec.atom(:ct) }

          it { expect(subject.additional_relations).to match_array([
              [subject, adsorbed_h],
              [subject, active_bond]
            ]) }
        end
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
