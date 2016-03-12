require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Lambda do
          subject { lda }

          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_const) { true }

          describe '#self.[]' do
            describe 'wrong vars' do
              it { expect { described_class[[], func0] }.not_to raise_error }

              it { expect { described_class[nil, func0] }.to raise_error }
              it { expect { described_class[[], type, func1] }.to raise_error }
              it { expect { described_class[[], x, func2] }.to raise_error }
            end

            describe 'wrong body' do
              it { expect { described_class[[], type] }.to raise_error }
              it { expect { described_class[[], var, wrong_seq] }.to raise_error }
            end
          end

          it_behaves_like :check_predicates

          describe '#code' do
            let(:code) do
              <<-CODE
[](Yo *obj) {
    simple();
    mono(x);
}
              CODE
            end
            it { expect(subject.code).to eq(code.rstrip) }
          end
        end

      end
    end
  end
end
