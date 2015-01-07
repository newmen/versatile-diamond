require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe NonPosition do
      describe '#self.[]' do
        it 'if face and dir the same then returns the same instance' do
          expect(NonPosition[param_100_front]).to eq(non_position_100_front)
        end

        it 'if no has face or dir then raise error' do
          expect { NonPosition[param_amorph] }.to raise_error NonPosition::Incomplete
        end
      end

      describe '#self.make_from another non position' do
        subject { NonPosition.make_from(non_position_110_cross) }
        it { should == non_position_110_cross }
      end

      describe '#face' do
        it { expect(non_position_100_front.face).to eq(100) }
        it { expect(non_position_100_cross.face).to eq(100) }
      end

      describe '#dir' do
        it { expect(non_position_100_front.dir).to eq(:front) }
        it { expect(non_position_100_cross.dir).to eq(:cross) }
      end

      describe '#==' do
        subject { non_position_110_front }

        it { expect(subject == NonPosition.new(110, :front)).to be_truthy }
        it { expect(subject == non_position_100_front).to be_falsey }
      end

      describe '#cross' do
        # could be?
        it { expect(non_position_100_front.cross).to eq(non_position_100_cross) }
        it { expect(non_position_100_cross.cross).to eq(non_position_100_front) }
      end

      describe '#params' do
        it { expect(non_position_110_front.params).to eq(param_110_front) }
        it { expect(non_position_100_cross.params).to eq(param_100_cross) }
      end

      describe '#it?' do
        subject { non_position_110_front }

        it { expect(subject.it?(face: 110, dir: :front)).to be_truthy }
        it { expect(subject.it?(face: 100, dir: :front)).to be_falsey }
        it { expect(subject.it?(param_110_front)).to be_truthy }
        it { expect(subject.it?(param_110_cross)).to be_falsey }
      end

      describe '#same?' do
        it { expect(non_position_100_front.same?(non_position_100_front)).to be_truthy }
        it { expect(non_position_100_front.same?(non_position_110_front)).to be_falsey }
        it { expect(non_position_100_front.same?(position_100_cross)).to be_falsey }
        it { expect(non_position_100_front.same?(bond_110_front)).to be_falsey }
      end

      describe '#belongs_to_crystal?' do
        it { expect(non_position_100_cross.belongs_to_crystal?).to be_truthy }
      end

      describe '#exist?' do
        it { expect(non_position_100_front.exist?).to be_falsey }
        it { expect(non_position_110_cross.exist?).to be_falsey }
      end
    end

  end
end
