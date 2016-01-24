require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Return do
          subject { ret }

          include_context :predefined_exprs
          let(:is_assign) { true }

          describe '#self.[]' do
            it { expect { described_class[x, y] }.to raise_error }
            it { expect { described_class[type] }.to raise_error }
            it { expect { described_class[small_cond] }.to raise_error }
            it { expect { described_class[func_args_seq] }.to raise_error }
          end

          it_behaves_like :check_predicates

          describe '#code' do
            it { expect(subject.code).to eq('return obj1->foo(x, x)') }
          end
        end

      end
    end
  end
end
