require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Position do
      describe '#self.[]' do
        it 'if face and dir the same then returns the same instance' do
          expect(Position[param_100_front]).to eq(position_100_front)
        end

        it 'if no has face or dir then raise error' do
          expect { Position[param_amorph] }.to raise_error Position::Incomplete
        end
      end

      describe '#self.make_from' do
        describe 'bond' do
          subject { Position.make_from(bond_100_front) }
          it { should == position_100_front }
        end

        describe 'poisition' do
          subject { Position.make_from(position_110_cross) }
          it { should == position_110_cross }
        end
      end

      describe '#face' do
        it { expect(position_100_front.face).to eq(100) }
        it { expect(position_100_cross.face).to eq(100) }
      end

      describe '#dir' do
        it { expect(position_100_front.dir).to eq(:front) }
        it { expect(position_100_cross.dir).to eq(:cross) }
      end

      describe '#==' do
        subject { position_110_front }

        it { expect(subject == Position.new(110, :front)).to be_truthy }
        it { expect(subject == position_100_front).to be_falsey }
      end

      describe '#cross' do
        it { expect(position_100_front.cross).to eq(position_100_cross) }
        it { expect(position_100_cross.cross).to eq(position_100_front) }
      end

      describe '#params' do
        it { expect(position_110_front.params).to eq(param_110_front) }
        it { expect(position_100_cross.params).to eq(param_100_cross) }
      end

      describe '#it?' do
        subject { position_110_front }

        it { expect(subject.it?(face: 110, dir: :front)).to be_truthy }
        it { expect(subject.it?(face: 100, dir: :front)).to be_falsey }
        it { expect(subject.it?(param_110_front)).to be_truthy }
        it { expect(subject.it?(param_110_cross)).to be_falsey }
      end

      describe '#same?' do
        it { expect(position_100_front.same?(position_100_cross)).to be_falsey }
        it { expect(position_100_front.same?(bond_110_front)).to be_falsey }
        it { expect(position_100_front.same?(bond_100_front)).to be_truthy }
      end

      describe '#belongs_to_crystal?' do
        it { expect(position_100_cross.belongs_to_crystal?).to be_truthy }
      end
    end

  end
end
