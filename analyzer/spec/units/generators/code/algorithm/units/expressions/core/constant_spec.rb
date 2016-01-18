require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Constant do
          subject { described_class['val'] }

          describe '#self.[]' do
            it { expect(subject).to be_a(described_class) }

            describe 'side spaces' do
              it { expect { described_class[''] }.not_to raise_error }

              it { expect { described_class[' '] }.to raise_error }
              it { expect { described_class[' hello'] }.to raise_error }
              it { expect { described_class['world '] }.to raise_error }
              it { expect { described_class["\t"] }.to raise_error }
              it { expect { described_class["\n"] }.to raise_error }
            end

            describe 'wrong type' do
              it { expect { described_class[123] }.not_to raise_error }
              it { expect { described_class[2.71] }.not_to raise_error }

              it { expect { described_class[Object.new] }.to raise_error }
              it { expect { described_class[Array.new] }.to raise_error }
              it { expect { described_class[Hash.new] }.to raise_error }
              it { expect { described_class[Set.new] }.to raise_error }
              it { expect { described_class[subject] }.to raise_error }
            end
          end

          describe '#+' do
            let(:sum) { subject + Constant['_second'] }
            it { expect(sum.code).to eq('val_second') }
          end

          describe '#code' do
            it { expect(subject.code).to eq('val') }
            it { expect(Constant[1].code).to eq('1') }
          end
        end

      end
    end
  end
end
