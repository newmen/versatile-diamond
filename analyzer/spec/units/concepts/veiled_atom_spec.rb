require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe VeiledAtom do
      describe '#same?' do
        it_behaves_like :check_same_veiled do
          subject { cd }
          let(:other) { c }
        end

        it_behaves_like :check_same_veiled do
          subject { activated_cd }
          let(:other) { activated_c }
        end
      end

      describe '#original_same?' do
        let(:x) { described_class.new(c) }
        let(:y) { described_class.new(activated_c) }
        it { expect(x.original_same?(y)).to be_truthy }
      end

      describe '#accurate_same?' do
        let(:x) { described_class.new(c) }
        let(:y) { described_class.new(c) }
        it { expect(x.accurate_same?(y)).to be_truthy }
      end
    end

  end
end
