require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificAtom do
      subject { described_class.new(n) }

      describe "#initialize" do
        subject do
          described_class.new(cd,
            options: [:active, :incoherent], monovalents: [:H])
        end
        it { subject.actives.should == 1 }
        it { subject.incoherent?.should be_true }
        it { subject.monovalents.should == [:H] }

        describe "from specific atom" do
          let(:child) { described_class.new(cd, ancestor: subject) }
          it { child.actives.should == 1 }
          it { child.incoherent?.should be_true }
          it { child.monovalents.should == [:H] }
        end
      end

      describe "#dup" do
        it { subject.dup.should_not == subject }
        it { activated_c.dup.actives.should == 1 }
        it { activated_cd.dup.lattice.should == diamond }
        it { activated_cd_hydride.dup.monovalents.should == [:H] }
      end

      describe "#name" do
        it { activated_n.name.should == :N }
        it { activated_c.name.should == :C }
      end

      describe "#valence" do
        it { activated_n.valence.should == 2 }
        it { activated_c.valence.should == 3 }
        it { extra_activated_cd.valence.should == 2 }
        it { SpecificAtom.new(c).valence.should == 4 }
      end

      describe "#original_valence" do
        it { activated_n.original_valence.should == 3 }
        it { activated_c.original_valence.should == 4 }
        it { extra_activated_cd.original_valence.should == 4 }
        it { SpecificAtom.new(c).original_valence.should == 4 }
      end

      describe "#actives" do
        it { subject.actives.should == 0 }

        it { activated_h.actives.should == 1 }
        it { activated_c.actives.should == 1 }
        it { activated_cd.actives.should == 1 }
        it { extra_activated_cd.actives.should == 2 }
      end

      %w(incoherent unfixed).each do |state|
        describe "##{state}!?" do
          describe "is set" do
            before { subject.send("#{state}!") }
            it { subject.send("#{state}?").should be_true }

            describe "already stated" do
              it { expect { subject.send("#{state}!") }.
                to raise_error SpecificAtom::AlreadyStated }
            end

            describe "reset state" do
              before { subject.send("not_#{state}!") }
              it { subject.send("#{state}?").should be_false }
            end
          end

          describe "is not set" do
            it { subject.send("#{state}?").should be_false }
            it { expect { subject.send("not_#{state}!") }.
              to raise_error SpecificAtom::NotStated }
          end
        end
      end

      describe "#monovalents" do
        it { activated_c.monovalents.should be_empty }
        it { c_chloride.monovalents.should == [:Cl] }
      end

      describe "#same?" do
        it { subject.same?(n).should be_false }
        it { n.same?(subject).should be_false }

        describe "same class instance" do
          let(:other) { SpecificAtom.new(n.dup) }

          shared_examples_for "equal if both and not if just one" do
            it "both atoms" do
              do_with(subject)
              do_with(other)
              subject.same?(other).should be_true
            end

            it "just one atom" do
              do_with(other)
              subject.same?(other).should be_false
            end
          end

          it_behaves_like "equal if both and not if just one" do
            def do_with(atom); atom.active! end
          end

          it_behaves_like "equal if both and not if just one" do
            def do_with(atom); atom.incoherent! end
          end

          it_behaves_like "equal if both and not if just one" do
            def do_with(atom); atom.unfixed! end
          end

          it_behaves_like "equal if both and not if just one" do
            def do_with(atom); atom.use!(h) end
          end
        end
      end

      describe "#diff" do
        it { unfixed_c.diff(c).should == [] }
        it { unfixed_activated_c.diff(c).should == [] }
        it { unfixed_c.diff(SpecificAtom.new(c)).should == [] }

        it { incoherent_cd.diff(cd).should == [] }
        it { activated_incoherent_cd.diff(cd).should == [] }
        it { activated_incoherent_cd.diff(activated_cd).should == [] }
        it { activated_incoherent_cd.diff(bridge.atom(:cr)).should == [] }
        it { activated_cd.diff(bridge.atom(:cr)).should == [] }

        it { activated_c.diff(unfixed_c).should == [:unfixed] }
        it { activated_c.diff(unfixed_activated_c).should == [:unfixed] }
        it { activated_cd.diff(incoherent_cd).should == [:incoherent] }
        it { activated_cd.diff(activated_incoherent_cd).
          should == [:incoherent] }
      end

      describe "#apply_diff" do
        before(:each) { activated_c.apply_diff([:unfixed, :incoherent]) }
        it { activated_c.incoherent?.should be_true }
        it { activated_c.unfixed?.should be_true }
      end

      describe "#relevants" do
        it { activated_c.relevants.should == [] }
        it { unfixed_c.relevants.should == [:unfixed] }
        it { unfixed_activated_c.relevants.should == [:unfixed] }
        it { incoherent_cd.relevants.should == [:incoherent] }
        it { activated_incoherent_cd.relevants.should == [:incoherent] }
      end

      it_behaves_like "#lattice" do
        let(:target) { n }
        let(:reference) { subject }
      end

      describe "#relations_in" do
        let(:spec) { activated_bridge }

        describe ":ct of activated_bridge" do
          subject { spec.atom(:ct) }
          it { subject.relations_in(spec).size.should == 3 }
          it { subject.relations_in(spec).should include(
              :active,
              [spec.atom(:cr), bond_110_cross],
              [spec.atom(:cl), bond_110_cross]
            ) }
        end

        describe ":cr of activated_bridge" do
          subject { spec.atom(:cr) }
          it { subject.relations_in(spec).size.should == 4 }
          it { subject.relations_in(spec).map(&:last).should include(
              bond_110_front, bond_110_cross, bond_110_cross,
              position_100_front
            ) }
        end

        describe ":ct of activated_hydrogenated_bridge" do
          let(:spec) { activated_hydrogenated_bridge }
          subject { spec.atom(:ct) }
          it { subject.relations_in(spec).size.should == 4 }
          it { subject.relations_in(spec).should include(
              :active, :H,
              [spec.atom(:cr), bond_110_cross],
              [spec.atom(:cl), bond_110_cross]
            ) }
        end
      end

      describe "#to_s" do
        it { activated_c.to_s.should == "C[*]" }
        it { unfixed_activated_c.to_s.should == "C[*, u]" }
        it { activated_cd.to_s.should == "C%d[*]" }
        it { activated_cd_hydride.to_s.should == "C%d[*, H]" }
        it { incoherent_cd.to_s.should == "C%d[i]" }
        it { activated_incoherent_cd.to_s.should == "C%d[*, i]" }
        it { incoherent_cd_hydride.to_s.should == "C%d[H, i]" }

        it { c_chloride.to_s.should == "C[Cl]" }
        it { c_hydride.to_s.should == "C[H]" }
        it { cd_hydride.to_s.should == "C%d[H]" }
      end
    end

  end
end
