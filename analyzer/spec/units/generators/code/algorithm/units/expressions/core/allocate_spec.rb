require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Allocate do
          subject { described_class[type, x, template_args: [type]] }

          include_context :predefined_exprs
          let(:is_expr) { true }

          describe '#self.[]' do
            it_behaves_like :check_expr_init

            describe 'invalid arguments' do
              it { expect { described_class[func1] }.to raise_error }
              it { expect { described_class[x] }.to raise_error }
              it { expect { described_class[template_args: [x]] }.to raise_error }
            end
          end

          it_behaves_like :check_predicates

          describe '#code' do
            it { expect(subject.code).to eq('new Yo<Yo>(x)') }
            it { expect(described_class[type, x, y].code).to eq('new Yo(x, y)') }
          end
        end

      end
    end
  end
end
