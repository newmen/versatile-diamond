require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Constant do
          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_const) { true }

          describe '#self.[]' do
            it { expect(x).to be_a(described_class) }

            it_behaves_like :check_const_init

            describe 'side spaces' do
              it { expect { described_class[''] }.not_to raise_error }
            end

            describe 'wrong type' do
              it { expect { described_class[123] }.not_to raise_error }
              it { expect { described_class[2.71] }.not_to raise_error }
              it { expect { described_class[x] }.to raise_error }
            end
          end

          describe '#+' do
            it { expect { x + described_class['other'] }.to raise_error }
          end

          it_behaves_like :check_predicates do
            subject { x }
          end

          it_behaves_like :check_predicates do
            subject { num }
            let(:is_scalar) { true }
          end

          describe '#code' do
            it { expect(x.code).to eq('x') }
            it { expect(num.code).to eq('5') }
          end
        end

      end
    end
  end
end
