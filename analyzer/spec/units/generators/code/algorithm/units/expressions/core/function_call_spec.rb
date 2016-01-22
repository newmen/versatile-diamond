require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe FunctionCall do
          include_context :predefined_exprs
          let(:is_expr) { true }

          describe '#self.[]' do
            it { expect(func0).to be_a(described_class) }
            it { expect(func1).to be_a(described_class) }
            it { expect(tfunc0).to be_a(described_class) }
            it { expect(method).to be_a(described_class) }

            it_behaves_like :check_expr_init

            describe 'wrong type' do
              it { expect { described_class[type] }.to raise_error }
              it { expect { described_class[func1] }.to raise_error }
              it { expect { described_class[x] }.to raise_error }
            end

            describe 'invalid arguments' do
              it { expect { described_class[type] }.to raise_error }
              it { expect { described_class[template_args: [x]] }.to raise_error }
              it { expect { described_class[target: x] }.to raise_error }
            end
          end

          it_behaves_like :check_predicates do
            subject { func0 }
          end

          describe '#code' do
            it { expect(func0.code).to eq('simple()') }
            it { expect(func1.code).to eq('mono(x)') }
            it { expect(func2.code).to eq('many(x, y)') }
            it { expect(tfunc0.code).to eq('templ<Yo, 5>()') }
            it { expect(method.code).to eq('obj->method(5)') }
          end

          describe '#name' do
            it { expect(func0.name.code).to eq('simple') }
            it { expect(func1.name.code).to eq('mono') }
            it { expect(func2.name.code).to eq('many') }
            it { expect(tfunc0.name.code).to eq('templ') }
            it { expect(method.name.code).to eq('method') }
          end
        end

      end
    end
  end
end
