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

          describe '#self.[]' do
            it { expect { described_class[:v, type] }.to raise_error }
            it { expect { described_class[nil, type] }.to raise_error }
            it { expect { described_class[:v, x] }.to raise_error }
            it { expect { described_class[:v, type, ''] }.to raise_error }
            it { expect { described_class[:v, type, 123] }.to raise_error }
            it { expect { described_class[:v, type, 'a', 'v'] }.to raise_error }
          end

          it_behaves_like :check_predicates

          describe '#instance' do
            it { expect(subject.instance).to eq(:var) }
          end

          describe '#code' do
            it { expect(subject.code).to eq('obj') }
            it { expect { described_class[:v, type].code }.to raise_error }
          end

          describe '#define_var' do
            it { expect(subject.define_var.code).to eq('Yo *obj') }
            it { expect(vvl.define_var.code).to eq('Yo *val = simple()') }
          end

          describe '#define_arg' do
            it { expect(subject.define_arg.code).to eq('Yo *obj') }
            it { expect(vvl.define_arg.code).to eq('Yo *val') }
          end

          describe '#call' do
            it { expect(method.code).to eq('obj->foo(x, x)') }
            it { expect(vvl.call('bar').code).to eq('val->bar()') }
          end

          describe '#obj?' do
            it { expect(subject.obj?).to be_truthy }
            it { expect(scv.obj?).to be_falsey }
          end
        end

      end
    end
  end
end
