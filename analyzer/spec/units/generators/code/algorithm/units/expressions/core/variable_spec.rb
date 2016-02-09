require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Variable do
          subject { var }

          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_var) { true }
          let(:is_obj) { true }

          describe '#self.[]' do
            it { expect { described_class[nil, :v, type] }.to raise_error }
            it { expect { described_class[namer, nil, type] }.to raise_error }
            it { expect { described_class[namer, :v, x] }.to raise_error }
            it { expect { described_class[namer, :v, type, ''] }.to raise_error }
            it { expect { described_class[namer, :v, type, 123] }.to raise_error }
            it { expect { described_class[namer, :v, type, 'a', 'v'] }.to raise_error }
          end

          it_behaves_like :check_predicates
          it_behaves_like :check_predicates do
            subject { scv }
            let(:is_obj) { false }
          end

          describe '#code' do
            it { expect(subject.code).to eq('obj1') }
            it { expect { described_class[namer, :v, type].code }.to raise_error }
          end

          describe '#define_var' do
            it { expect(subject.define_var.code).to eq('Yo *obj1') }
            it { expect(vvl.define_var.code).to eq('Yo *val1 = simple()') }
          end

          describe '#define_arg' do
            it { expect(subject.define_arg.code).to eq('Yo *obj1') }
            it { expect(vvl.define_arg.code).to eq('Yo *val1') }
          end

          describe '#call' do
            it { expect(method.code).to eq('obj1->foo(x, x)') }
            it { expect(vvl.call('bar').code).to eq('val1->bar()') }
          end
        end

      end
    end
  end
end
