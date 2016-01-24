require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Assert do
          subject { assert }

          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_assign) { true }

          describe '#self.[]' do
            it { expect { described_class[type] }.to raise_error }
            it { expect { described_class[small_cond] }.to raise_error }
            it { expect { described_class[func_args_seq] }.to raise_error }
          end

          it_behaves_like :check_predicates

          describe '#code' do
            it { expect(assert.code).to eq('assert(simple())') }
          end

          describe '#name' do
            it { expect(assert.name.code).to eq('assert') }
          end
        end

      end
    end
  end
end
