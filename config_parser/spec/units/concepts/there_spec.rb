require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe There do
      describe "#where" do
        it { on_end.where.should == at_end }
        it { on_middle.where.should == at_middle }
      end

      describe "#target_specs" do
        it { on_end.target_specs.should == [dimer, dimer] }
        it { on_middle.target_specs.should == [dimer, dimer] }
        it { there_methyl.target_specs.should == [dimer] }
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
            [dimer, dimer.atom(:cl)] => [
              [[dimer, dimer.atom(:cl)], position_cross]
            ],
            [dimer, dimer.atom(:cr)] => [
              [[dimer, dimer.atom(:cr)], position_cross]
            ]
          } }

        it { on_middle.positions.should == {
            [dimer, dimer.atom(:cl)] => [
              [[dimer, dimer.atom(:cl)], position_cross],
              [[dimer, dimer.atom(:cl)], position_cross],
            ],
            [dimer, dimer.atom(:cr)] => [
              [[dimer, dimer.atom(:cr)], position_cross],
              [[dimer, dimer.atom(:cr)], position_cross],
            ]
          } }

        it { there_methyl.positions.should == {
            [dimer, dimer.atom(:cr)] => [
              [[methyl_on_bridge, methyl_on_bridge.atom(:cb)], position_front]
            ]
          } }

      end

      it_behaves_like "#swap_source" do
        subject { on_end }
        let(:method) { :env_specs }
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
