require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SpecificAtom do
      subject { described_class.new(n) }

      describe "#initialize" do
        subject { described_class.new(cd, options: [:active, :incoherent]) }
        it { subject.actives.should == 1 }
        it { subject.incoherent?.should be_true }

        describe "from specific atom" do
          let(:child) { described_class.new(cd, ancestor: subject) }
          it { child.actives.should == 1 }
          it { child.incoherent?.should be_true }
        end
      end

      describe "#dup" do
        it { subject.dup.should_not == subject }
        it { activated_c.dup.actives.should == 1 }
        it { activated_cd.dup.lattice.should == diamond }
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

      describe "#same?" do
        it { subject.same?(n).should be_false }
        it { n.same?(subject).should be_false }

        describe "same class instance" do
          let(:other) { SpecificAtom.new(n.dup) }

          it "both atoms is activated" do
            subject.active!
            other.active!
            subject.same?(other).should be_true
          end

          it "just one atom is activated" do
            other.active!
            subject.same?(other).should be_false
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
        it { activated_cd.relations_in(activated_bridge).size.should == 3 }
        it { activated_bridge.atom(:cr).relations_in(activated_bridge).size.
          should == 4 }
      end
    end

  end
end