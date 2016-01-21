require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Type do
          subject { described_class['ClassName'] }

          describe '#self.[]' do
            it { expect(subject).to be_a(described_class) }

            describe 'side spaces' do
              it { expect { described_class[''] }.to raise_error }
              it { expect { described_class[' '] }.to raise_error }
              it { expect { described_class[' hello'] }.to raise_error }
              it { expect { described_class['world '] }.to raise_error }
            end

            describe 'wrong type' do
              it { expect { described_class[123] }.to raise_error }
              it { expect { described_class[2.71] }.to raise_error }
              it { expect { described_class[Object.new] }.to raise_error }
              it { expect { described_class[Array.new] }.to raise_error }
              it { expect { described_class[Hash.new] }.to raise_error }
              it { expect { described_class[Set.new] }.to raise_error }
              it { expect { described_class[subject] }.to raise_error }
            end
          end

          describe '#expr?' do
            it { expect(subject.expr?).to be_falsey }
          end

          describe '#var?' do
            it { expect(subject.var?).to be_falsey }
          end

          describe '#const?' do
            it { expect(subject.const?).to be_truthy }
          end

          describe '#type?' do
            it { expect(subject.type?).to be_truthy }
          end

          describe '#op?' do
            it { expect(subject.op?).to be_falsey }
          end

          describe '#ptr' do
            it { expect(subject.ptr.code).to eq('ClassName *') }
          end

          describe '#member_ref' do
            let(:func) { Constant['func'] }
            it { expect(subject.member_ref(func).code).to eq('&ClassName::func') }
          end
        end

      end
    end
  end
end
