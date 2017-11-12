require 'spec_helper'

module VersatileDiamond
  module Generators
    module Formula

      describe CrystalMatrix do
        let(:one_mx) { described_class.new(a_cr) }
        let(:two_mx) do
          cr_steps.first.place!(a_cl)
          one_mx
        end
        let(:three_mx) do
          cl_steps.last.place!(a_ct)
          two_mx
        end

        let(:a_cr) { bridge_base.atom(:cr) }
        let(:a_cl) { bridge_base.atom(:cl) }
        let(:a_ct) { bridge_base.atom(:ct) }

        let(:n_cr) { one_mx.node_with(a_cr) }
        let(:n_cl) { two_mx.node_with(a_cl) }
        let(:n_ct) { three_mx.node_with(a_ct) }

        let(:cr_steps) { one_mx.steps_by(position_100_front, n_cr) }
        let(:cl_steps) { two_mx.steps_by(bond_110_front, n_cl) }
        let(:ct_steps) { three_mx.steps_by(bond_110_cross, n_ct) }

        describe '#each_nonempty' do
          it { expect(one_mx.each_nonempty.map(&:atom)).to eq([a_cr]) }
          it { expect(two_mx.each_nonempty.map(&:atom)).to eq([a_cr, a_cl]) }
          it { expect(three_mx.each_nonempty.map(&:atom)).to eq([a_cr, a_cl, a_ct]) }
        end

        describe '#node_with' do
          it { expect(n_cr.atom).to eq(a_cr) }
          it { expect(n_cl.atom).to eq(a_cl) }
          it { expect(n_ct.atom).to eq(a_ct) }
        end

        describe '#steps_by' do
          it { expect(cr_steps.map(&:coords)).to eq([[-1, 0, 0], [1, 0, 0]]) }
          it { expect(cl_steps.map(&:coords)).to eq([[-2, 0, 1], [-1, 0, 1]]) }
          it { expect(ct_steps.map(&:coords)).to eq([[-1, 0, 0], [0, 0, 0]]) }
        end
      end

    end
  end
end
