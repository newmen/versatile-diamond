require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe FunctionCall do
          subject { func0 }

          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_call) { true }

          describe '#self.[]' do
            it { expect(func1).to be_a(described_class) }
            it { expect(tfunc0).to be_a(described_class) }

            it_behaves_like :check_expr_init

            describe 'invalid arguments' do
              it { expect { described_class[type] }.to raise_error }
              it { expect { described_class[func1] }.to raise_error }
              it { expect { described_class[x] }.to raise_error }
              it { expect { described_class[template_args: [x]] }.to raise_error }
            end
          end

          it_behaves_like :check_predicates

          describe '#code' do
            it { expect(subject.code).to eq('simple()') }
            it { expect(func1.code).to eq('mono(x)') }
            it { expect(func2.code).to eq('many(x, y)') }
            it { expect(tfunc0.code).to eq('templ<Yo, 5>()') }
          end

          describe '#name' do
            it { expect(subject.name.code).to eq('simple') }
            it { expect(func1.name.code).to eq('mono') }
            it { expect(func2.name.code).to eq('many') }
            it { expect(tfunc0.name.code).to eq('templ') }
          end

          describe '#call' do
            it { expect(subject.call('hello').code).to eq('simple()->hello()') }
            it { expect(func1.call('f', Constant[0]).code).to eq('mono(x)->f(0)') }
          end

          describe '#member' do
            it { expect(subject.member('hello').code).to eq('simple().hello()') }
            it { expect(func1.member('f', Constant[0]).code).to eq('mono(x).f(0)') }
          end
        end

      end
    end
  end
end
