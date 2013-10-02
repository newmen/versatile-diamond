require 'spec_helper'

module VersatileDiamond
  module Tools

    describe AtomClassifier do
      describe AtomClassifier::AtomProperties do
        let(:dc) { AtomClassifier::AtomProperties }

        let(:bridge_ct) { dc.new(bridge, bridge.atom(:ct)) }
        let(:bridge_cr) { dc.new(bridge, bridge.atom(:cr)) }
        let(:dimer_cr) { dc.new(bridge, bridge.atom(:cr)) }
        let(:dimer_cl) { dc.new(bridge, bridge.atom(:cl)) }

        let(:ab_ct) do
          dc.new(activated_bridge, activated_bridge.atom(:ct))
        end
        let(:aib_ct) do
          aib = activated_incoherent_bridge
          dc.new(aib, aib.atom(:ct))
        end

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

        describe "#unrelevanted" do
          it { bridge_ct.unrelevanted.should == bridge_ct }
          it { bridge_ct.should == bridge_ct.unrelevanted }

          it { bridge_ct.should_not == ab_ct.unrelevanted }
          it { ab_ct.unrelevanted.should_not == bridge_ct }

          it { ab_ct.unrelevanted.should == aib_ct.unrelevanted }
          it { aib_ct.unrelevanted.should == ab_ct.unrelevanted }
        end
      end

    end

  end
end
