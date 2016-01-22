module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core
        module Support

          module StatementsExamples
            shared_context :predicate_values do
              let(:is_expr) { false }
              let(:is_var) { false }
              let(:is_const) { false }
              let(:is_scalar) { false }
              let(:is_type) { false }
              let(:is_op) { false }
              let(:is_tin) { false }
            end

            shared_context :predefined_exprs do
              include_context :predicate_values

              let(:namer) { Algorithm::Units::NameRemember.new }

              let(:x) { Constant['x'] }
              let(:y) { Constant['y'] }
              let(:type) { Type['Yo'] }
              let(:num) { Constant[5] }
              let(:var) { Variable[namer, Object.new, type, 'obj'] }

              let(:func0) { FunctionCall['simple'] }
              let(:func1) { FunctionCall['mono', x] }
              let(:func2) { FunctionCall['many', x, y] }
              let(:tfunc0) { FunctionCall['templ', template_args: [type, num]] }

              let(:member) { OpNs[type, func0] }

              let(:func_args_seq) { OpSequence[var, x, num] }
              let(:tmpl_args_seq) { OpSequence[type, num] }
              let(:wrong_seq) { OpSequence[x, type] }
            end

            shared_context :predefined_exprs_for_ops do
              include_context :predefined_exprs
              let(:is_op) { true }
            end

            shared_examples_for :check_const_init do
              describe 'side spaces' do
                it { expect { described_class[' '] }.to raise_error }
                it { expect { described_class[' hello'] }.to raise_error }
                it { expect { described_class['world '] }.to raise_error }
                it { expect { described_class["\t"] }.to raise_error }
                it { expect { described_class["\n"] }.to raise_error }
              end

              describe 'wrong type' do
                it { expect { described_class[Object.new] }.to raise_error }
                it { expect { described_class[Array.new] }.to raise_error }
                it { expect { described_class[Hash.new] }.to raise_error }
                it { expect { described_class[Set.new] }.to raise_error }
              end
            end

            shared_examples_for :check_expr_init do
              it_behaves_like :check_const_init

              describe 'side spaces' do
                it { expect { described_class[''] }.to raise_error }
              end

              describe 'wrong type' do
                it { expect { described_class[123] }.to raise_error }
                it { expect { described_class[2.71] }.to raise_error }
              end
            end

            shared_examples_for :check_predicates do
              it { expect(subject.expr?).to eq(is_expr) }
              it { expect(subject.var?).to eq(is_var) }
              it { expect(subject.const?).to eq(is_const) }
              it { expect(subject.scalar?).to eq(is_scalar) }
              it { expect(subject.type?).to eq(is_type) }
              it { expect(subject.op?).to eq(is_op) }
              it { expect(subject.tin?).to eq(is_tin) }
            end
          end

        end
      end
    end
  end
end
