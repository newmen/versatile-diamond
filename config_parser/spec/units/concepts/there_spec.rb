require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe There do
      let(:ai_bridge) { activated_incoherent_bridge }
      let(:ai_bridge_dup) { ai_bridge.dup }

      describe "#dup" do
        subject { on_end.dup }
        it { should_not == on_end }
        it { subject.where.should == on_end.where }
        it { subject.positions.should == on_end.positions }
        it { subject.positions.object_id.
          should_not == on_end.positions.object_id }

        describe "target swapping doesn't change duplicate" do
          before { subject.swap_target(ai_bridge, ai_bridge_dup) }
          it { subject.target_specs.should_not == on_end.target_specs }
        end
      end

      describe "#where" do
        it { on_end.where.should == at_end }
        it { on_middle.where.should == at_middle }
      end

      describe "#target_specs" do
        it { on_end.target_specs.should == [activated_bridge, ai_bridge] }
        it { on_middle.target_specs.should == [activated_bridge, ai_bridge] }
        it { there_methyl.target_specs.should == [activated_bridge] }
      end

      describe "#env_specs" do
        it { on_end.env_specs.should == [dimer] }
        it { on_middle.env_specs.should == [dimer, dimer] }
        it { there_methyl.env_specs.should == [methyl_on_bridge] }
      end

      describe "#description" do
        it { on_end.description.should == 'at end of dimers row' }
        it { there_methyl.description.should == 'chain neighbour methyl' }
      end

      describe "#positions" do
        it { on_end.positions.should == {
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cl)], position_100_cross]
            ],
            [ai_bridge, ai_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cr)], position_100_cross]
            ]
          } }

        it { on_middle.positions.should == {
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cl)], position_100_cross],
              [[dimer, dimer.atom(:cl)], position_100_cross],
            ],
            [ai_bridge, ai_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cr)], position_100_cross],
              [[dimer, dimer.atom(:cr)], position_100_cross],
            ]
          } }

        it { there_methyl.positions.should == {
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [
                [methyl_on_bridge, methyl_on_bridge.atom(:cb)],
                position_100_front
              ]
            ]
          } }

      end

      it_behaves_like "check specs after swap_source" do
        subject { on_end }
        let(:method) { :env_specs }
      end

      describe "#swap_source" do
        before { on_end.swap_source(dimer, dimer_dup_ff) }
        it { on_end.positions.should == {
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer_dup_ff, dimer_dup_ff.atom(:cl)], position_100_cross]
            ],
            [ai_bridge, ai_bridge.atom(:ct)] => [
              [[dimer_dup_ff, dimer_dup_ff.atom(:cr)], position_100_cross]
            ]
          } }
      end

      describe "#swap_target" do
        before { on_end.swap_target(ai_bridge, ai_bridge_dup) }

        it { on_end.positions.should == {
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cl)], position_100_cross]
            ],
            [ai_bridge_dup, ai_bridge_dup.atom(:ct)] => [
              [[dimer, dimer.atom(:cr)], position_100_cross]
            ]
          } }
      end

      describe "#same?" do
        let(:same) do
          at_end.concretize(
            two: [dimer, dimer.atom(:cl)], one: [dimer, dimer.atom(:cr)])
        end

        it { on_end.same?(same).should be_true }
        it { on_end.same?(on_middle).should be_false }
        it { on_middle.same?(on_end).should be_false }
        it { on_end.same?(there_methyl).should be_false }
      end

      describe "#cover?" do
        it { on_end.cover?(on_middle).should be_true }
        it { on_middle.cover?(on_end).should be_false }
        it { there_methyl.cover?(on_end).should be_false }
      end

      describe "#size" do
        it { on_end.size.should == 6 }
        it { on_middle.size.should == 12 }
        it { there_methyl.size.should == 4 }
      end
    end

  end
end
