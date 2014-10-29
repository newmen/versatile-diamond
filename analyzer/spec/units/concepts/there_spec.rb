require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe There do
      let(:ai_bridge) { activated_incoherent_bridge }
      let(:ai_bridge_dup) { ai_bridge.dup }

      describe '#dup' do
        subject { on_end.dup }
        it { should_not == on_end }
        it { expect(subject.where).to eq(on_end.where) }
        it { expect(subject.positions).to eq(on_end.positions) }
        it { expect(subject.positions.object_id).
          not_to eq(on_end.positions.object_id) }

        describe "target swapping doesn't change duplicate" do
          before { subject.swap_target(ai_bridge, ai_bridge_dup) }
          it { expect(subject.target_specs).not_to eq(on_end.target_specs) }
        end
      end

      describe '#where' do
        it { expect(on_end.where).to eq(at_end) }
        it { expect(on_middle.where).to eq(at_middle) }
      end

      describe '#target_specs' do
        it { expect(on_end.target_specs).
          to match_array([activated_bridge, ai_bridge]) }
        it { expect(on_middle.target_specs).
          to match_array([activated_bridge, ai_bridge]) }
        it { expect(there_methyl.target_specs).to eq([activated_bridge]) }
      end

      describe '#env_specs' do
        it { expect(on_end.env_specs).to eq([dimer]) }
        it { expect(on_middle.env_specs).to match_array([dimer, dimer]) }
        it { expect(there_methyl.env_specs).to eq([methyl_on_bridge]) }
      end

      describe '#description' do
        it { expect(on_end.description).to eq('at end of dimers row') }
        it { expect(there_methyl.description).to eq('chain neighbour methyl') }
      end

      describe '#positions' do
        it { expect(on_end.positions).to match_graph({
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cl)], position_100_cross]
            ],
            [ai_bridge, ai_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cr)], position_100_cross]
            ]
          }) }

        it { expect(on_middle.positions).to match_graph({
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cl)], position_100_cross],
              [[dimer, dimer.atom(:cl)], position_100_cross],
            ],
            [ai_bridge, ai_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cr)], position_100_cross],
              [[dimer, dimer.atom(:cr)], position_100_cross],
            ]
          }) }

        it { expect(there_methyl.positions).to match_graph({
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [
                [methyl_on_bridge, methyl_on_bridge.atom(:cb)],
                position_100_front
              ]
            ]
          }) }

      end

      it_behaves_like 'check specs after swap_source' do
        subject { on_end }
        let(:method) { :env_specs }
      end

      describe '#swap_source' do
        before { on_end.swap_source(dimer, dimer_dup_ff) }
        it { expect(on_end.positions).to match_graph({
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer_dup_ff, dimer_dup_ff.atom(:cl)], position_100_cross]
            ],
            [ai_bridge, ai_bridge.atom(:ct)] => [
              [[dimer_dup_ff, dimer_dup_ff.atom(:cr)], position_100_cross]
            ]
          }) }
      end

      describe '#swap_target' do
        before { on_end.swap_target(ai_bridge, ai_bridge_dup) }

        it { expect(on_end.positions).to match_graph({
            [activated_bridge, activated_bridge.atom(:ct)] => [
              [[dimer, dimer.atom(:cl)], position_100_cross]
            ],
            [ai_bridge_dup, ai_bridge_dup.atom(:ct)] => [
              [[dimer, dimer.atom(:cr)], position_100_cross]
            ]
          }) }
      end

      describe '#used_keynames_of' do
        it { expect(on_end.used_keynames_of(dimer)).to match_array([:cr, :cl]) }
        it { expect(on_middle.used_keynames_of(dimer)).to match_array([:cr, :cl]) }
        it { expect(there_methyl.used_keynames_of(methyl_on_bridge)).to eq([:cb]) }
      end

      describe '#same?' do
        let(:same) do
          at_end.concretize(
            two: [dimer, dimer.atom(:cl)], one: [dimer, dimer.atom(:cr)])
        end

        it { expect(on_end.same?(same)).to be_truthy }
        it { expect(on_end.same?(on_middle)).to be_falsey }
        it { expect(on_middle.same?(on_end)).to be_falsey }
        it { expect(on_end.same?(there_methyl)).to be_falsey }
      end

      describe '#cover?' do
        it { expect(on_end.cover?(on_middle)).to be_truthy }
        it { expect(on_middle.cover?(on_end)).to be_falsey }
        it { expect(there_methyl.cover?(on_end)).to be_falsey }
      end
    end

  end
end
