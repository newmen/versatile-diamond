require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe VeiledSpec do

      describe '#same?' do
        shared_examples_for :check_same do
          let(:veiled) { described_class.new(subject) }

          it { expect(subject.same?(veiled)).to be_truthy }
          it { expect(veiled.same?(subject)).to be_truthy }

          let(:other_veiled) { described_class.new(other) }
          it { expect(veiled.same?(other_veiled)).to be_falsey }
          it { expect(other_veiled.same?(veiled)).to be_falsey }
        end

        it_behaves_like :check_same do
          subject { bridge_base }
          let(:other) { dimer_base }
        end

        it_behaves_like :check_same do
          subject { activated_bridge }
          let(:other) { activated_dimer }
        end
      end

    end
  end
end
