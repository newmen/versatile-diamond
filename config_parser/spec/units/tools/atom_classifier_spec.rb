require 'spec_helper'

module VersatileDiamond
  module Tools

    describe AtomClassifier do
      let(:dc) { AtomClassifier::AtomProperties }

      let(:bridge_ct) { dc.new(bridge, bridge.atom(:ct)) }
      let(:bridge_cr) { dc.new(bridge, bridge.atom(:cr)) }
      let(:dimer_cr) { dc.new(dimer, dimer.atom(:cr)) }
      let(:dimer_cl) { dc.new(dimer, dimer.atom(:cl)) }

      let(:ad_cr) { dc.new(activated_dimer, activated_dimer.atom(:cr)) }
      let(:ab_ct) { dc.new(activated_bridge, activated_bridge.atom(:ct)) }
      let(:aib_ct) do
        aib = activated_incoherent_bridge
        dc.new(aib, aib.atom(:ct))
      end

      describe AtomClassifier::AtomProperties do
        describe "#==" do
          it { bridge_ct.should_not == bridge_cr }
          it { bridge_cr.should_not == bridge_ct }

          it { bridge_ct.should_not == dimer_cr }
          it { dimer_cr.should_not == bridge_ct }

          it { dimer_cl.should == dimer_cr }
          it { dimer_cr.should == dimer_cl }

          it { bridge_ct.should_not == ab_ct }
          it { ab_ct.should_not == bridge_ct }

          it { ab_ct.should_not == aib_ct }
          it { aib_ct.should_not == ab_ct }
        end

        describe "#contained_in?" do
          it { bridge_ct.contained_in?(bridge_cr).should be_true }
          it { bridge_ct.contained_in?(dimer_cr).should be_true }
          it { bridge_ct.contained_in?(ab_ct).should be_true }
          it { bridge_ct.contained_in?(aib_ct).should be_true }
          it { aib_ct.contained_in?(aib_ct).should be_true }
          it { dimer_cr.contained_in?(ad_cr).should be_true }

          it { ad_cr.contained_in?(dimer_cr).should be_false }
          it { dimer_cr.contained_in?(bridge_ct).should be_false }
          it { dimer_cr.contained_in?(bridge_cr).should be_false }
          it { ab_ct.contained_in?(bridge_cr).should be_false }
          it { bridge_cr.contained_in?(ab_ct).should be_false }
        end

        describe "#unrelevanted" do
          it { bridge_ct.unrelevanted.should == bridge_ct }
          it { bridge_ct.should == bridge_ct.unrelevanted }

          it { bridge_ct.should_not == ab_ct.unrelevanted }
          it { ab_ct.unrelevanted.should_not == bridge_ct }

          it { ab_ct.unrelevanted.should == aib_ct.unrelevanted }
          it { aib_ct.unrelevanted.should == ab_ct.unrelevanted }
        end

        describe "#size" do
          it { bridge_ct.size.should == 3.5 }
          it { bridge_cr.size.should == 5.5 }
          it { dimer_cr.size.should == 4.5 }
          it { ab_ct.size.should == 4.5 }
          it { aib_ct.size.should == 4.84 }
        end

        describe "#has_relevants?" do
          it { bridge_ct.has_relevants?.should be_false }
          it { bridge_cr.has_relevants?.should be_false }
          it { dimer_cr.has_relevants?.should be_false }
          it { ab_ct.has_relevants?.should be_false }

          it { aib_ct.has_relevants?.should be_true }
        end
      end

      subject { described_class.new }

      describe "#analyze" do
        before(:each) do
          [
            activated_bridge,
            dimer,
            activated_dimer,
            methyl_on_incoherent_bridge,
            high_bridge,
          ].each do |spec|
            subject.analyze(spec)
          end
        end

        describe "#each_props" do
          it { subject.each_props.should be_a(Enumerator) }
          it { subject.each_props.size.should == 9 }
          it { subject.each_props.to_a.should include(
              ab_ct, bridge_cr, dimer_cr
            ) }
        end

        describe "#organize_properties!" do
          def find(prop)
            subject.each_props.to_a[subject.index(prop)]
          end

          before(:each) { subject.organize_properties! }

          it { find(bridge_cr).smallests.should be_nil }
          it { find(dimer_cr).smallests.should be_nil }
          it { find(ab_ct).smallests.should be_nil }

          it { find(ad_cr).smallests.size.should == 2 }
          it { find(ad_cr).smallests.to_a.should include(dimer_cr, ab_ct) }
        end

        describe "#classify" do
          it { subject.classify(activated_bridge).should == {
              0 => ['^C.%d<', 2],
              1 => ['*C%d<', 1],
            } }

          it { subject.classify(dimer).should == {
              2 => ['-C%d<', 2],
              0 => ['^C.%d<', 4],
            } }

          it { subject.classify(activated_dimer).should == {
              3 => ['-*C%d<', 1],
              2 => ['-C%d<', 1],
              0 => ['^C.%d<', 4],
            } }

          it { subject.classify(methyl_on_incoherent_bridge).should == {
              4 => ['C~', 1],
              5 => ['~C:i%d<', 1],
              0 => ['^C.%d<', 2],
            } }

          it { subject.classify(high_bridge).should == {
              0 => ['^C.%d<', 2],
              7 => ['C=', 1],
              8 => ['=C%d<', 1],
            } }
        end

        describe "#index" do
          it { subject.index(bridge_cr).should == 0 }
          it { subject.index(bridge, bridge.atom(:cr)).should == 0 }

          it { subject.index(ab_ct).should == 1 }
          it { subject.index(activated_bridge, activated_bridge.atom(:ct)).
            should == 1 }
        end

        describe "#all_types_num" do
          it { subject.all_types_num.should == 9 }
        end

        describe "#notrelevant_types_num" do
          it { subject.notrelevant_types_num.should == 8 }
        end

        describe "has_relevants?" do
          it { subject.has_relevants?(0).should be_false }
          it { subject.has_relevants?(1).should be_false }
          it { subject.has_relevants?(2).should be_false }
          it { subject.has_relevants?(3).should be_false }
          it { subject.has_relevants?(4).should be_false }
          it { subject.has_relevants?(5).should be_true }
          it { subject.has_relevants?(6).should be_false }
          it { subject.has_relevants?(7).should be_false }
          it { subject.has_relevants?(8).should be_false }
        end
      end
    end

  end
end
