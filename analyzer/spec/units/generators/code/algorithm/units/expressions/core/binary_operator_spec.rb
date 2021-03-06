require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe BinaryOperator do
          include_context :predefined_exprs_for_ops

          describe 'OpCombine' do
            describe '#self.[]' do
              it { expect { OpCombine[x] }.to raise_error }
            end

            let(:is_tin) { true }

            describe 'one line' do
              it_behaves_like :check_predicates
              subject { OpCombine[x, y] }

              describe '#code' do
                let(:code) do
                  <<-CODE
x;
y;
                  CODE
                end
                it { expect(subject.code).to eq(code.rstrip) }
              end
            end

            describe 'multi lines' do
              it_behaves_like :check_predicates
              subject { OpCombine[assign, for_loop] }

              describe '#code' do
                let(:code) do
                  <<-CODE
Yo *x = y;
for (int i = 0; i < 3; ++i)
{
    simple();
    mono(x);
}
                  CODE
                end
                it { expect(subject.code).to eq(code.rstrip) }
              end
            end
          end

          describe 'AlgebraicOperator' do
            shared_examples_for :check_algebraic do
              describe '#self.[]' do
                it { expect { op_class[type] }.to raise_error }
                it { expect { op_class[x, type] }.to raise_error }
                it { expect { op_class[y, small_cond] }.to raise_error }
              end

              it_behaves_like :check_predicates
              let(:is_expr) { true }
            end

            describe 'chain possible' do
              shared_examples_for :check_chain_op do
                subject { op_class[x] }

                it_behaves_like :check_algebraic

                describe '#code' do
                  describe 'one' do
                    it { expect(op_class[x].code).to eq('x') }
                  end

                  describe 'many' do
                    let(:code) { "x #{mark} y #{mark} simple()" }
                    it { expect(op_class[x, y, func0].code).to eq(code) }
                  end
                end
              end

              it_behaves_like :check_chain_op do
                let(:op_class) { OpAnd }
                let(:mark) { '&&' }
              end

              it_behaves_like :check_chain_op do
                let(:op_class) { OpOr }
                let(:mark) { '||' }
              end

              it_behaves_like :check_chain_op do
                let(:op_class) { OpPlus }
                let(:mark) { '+' }
              end

              it_behaves_like :check_chain_op do
                let(:op_class) { OpMinus }
                let(:mark) { '-' }
              end

              it_behaves_like :check_chain_op do
                let(:op_class) { OpMul }
                let(:mark) { '*' }
              end
            end

            describe 'comparation' do
              shared_examples_for :check_comp_op do
                subject { op_class[y, func1] }

                it_behaves_like :check_algebraic

                describe '#self.[]' do
                  it { expect { op_class[x] }.to raise_error }
                  it { expect { op_class[x, x, x] }.to raise_error }
                end

                describe '#code' do
                  it { expect(subject.code).to eq("y #{mark} mono(x)") }
                end
              end

              it_behaves_like :check_comp_op do
                let(:op_class) { OpEq }
                let(:mark) { '==' }
              end

              it_behaves_like :check_comp_op do
                let(:op_class) { OpNotEq }
                let(:mark) { '!=' }
              end
            end
          end

          describe 'OpSequence' do
            describe '#self.[]' do
              it { expect { OpSequence[small_cond] }.to raise_error }
            end

            subject { func_args_seq }
            it_behaves_like :check_predicates

            describe '#code' do
              it { expect(subject.code).to eq('obj, x, 5') }
              it { expect(tmpl_args_seq.code).to eq('Yo, 5') }
              it { expect(wrong_seq.code).to eq('x, Yo') }
            end
          end

          describe 'OpSeparate' do
            subject { OpSeparate[x, y] }
            it_behaves_like :check_predicates

            describe '#code' do
              it { expect(subject.code).to eq('x; y') }
            end
          end

          describe 'call operator' do
            shared_examples_for :check_errors_and_predicates do
              it { expect { op_class[x] }.to raise_error }
              it { expect { op_class[type] }.to raise_error }
              it { expect { op_class[type, func0] }.to raise_error }
              it { expect { op_class[small_cond, x] }.to raise_error }
              it { expect { op_class[var, num] }.to raise_error }
              it { expect { op_class[var, type] }.to raise_error }
              it { expect { op_class[var, small_cond] }.to raise_error }
              it { expect { op_class[var, OpAnd[x, y]] }.to raise_error }

              let(:is_expr) { true }
              let(:is_call) { true }
              let(:is_op) { false }

              it_behaves_like :check_predicates
            end

            describe 'OpCall' do
              subject { OpCall[var, OpCall[var, func2]] }

              it_behaves_like :check_errors_and_predicates do
                let(:op_class) { OpCall }
              end

              describe '#code' do
                it { expect(subject.code).to eq('obj->obj->many(x, y)') }
                it { expect(OpCall[var, x].code).to eq('obj->x') }
                it { expect(OpCall[var, var].code).to eq('obj->obj') }
                it { expect(OpCall[var, tfunc0].code).to eq('obj->templ<Yo, 5>()') }
              end
            end

            describe 'OpDot' do
              subject { OpDot[var, OpDot[var, func2]] }

              it_behaves_like :check_errors_and_predicates do
                let(:op_class) { OpDot }
              end

              describe '#code' do
                it { expect(subject.code).to eq('obj.obj.many(x, y)') }
                it { expect(OpDot[var, x].code).to eq('obj.x') }
                it { expect(OpDot[var, var].code).to eq('obj.obj') }
                it { expect(OpDot[var, tfunc0].code).to eq('obj.templ<Yo, 5>()') }
              end
            end
          end

          describe 'OpNs' do
            it { expect { OpNs[x] }.to raise_error }
            it { expect { OpNs[type] }.to raise_error }
            it { expect { OpNs[x, y] }.to raise_error }
            it { expect { OpNs[num, y] }.to raise_error }
            it { expect { OpNs[var, x] }.to raise_error }
            it { expect { OpNs[type, small_cond] }.to raise_error }
            it { expect { OpNs[type, OpOr[x, y]] }.to raise_error }

            subject { OpNs[type, func1.name] }
            let(:is_op) { false }
            let(:is_expr) { true }

            it_behaves_like :check_predicates
            it_behaves_like :check_predicates do
              subject { OpNs[type, type] }
              let(:is_expr) { false }
              let(:is_type) { true }
            end

            describe '#code' do
              it { expect(subject.code).to eq('Yo::mono') }
              it { expect(member.code).to eq('Yo::simple') }
              it { expect(OpNs[type, var].code).to eq('Yo::obj') }
              it { expect(OpNs[type, member].code).to eq('Yo::Yo::simple') }
              it { expect(OpNs[type, type, type].code).to eq('Yo::Yo::Yo') }
            end
          end

          describe 'OpLess' do
            it { expect { OpLess[x] }.to raise_error }
            it { expect { OpLess[x, y, y] }.to raise_error }
            it { expect { OpLess[type, num] }.to raise_error }
            it { expect { OpLess[num, type] }.to raise_error }

            subject { OpLess[x, num] }
            let(:is_expr) { true }

            it_behaves_like :check_predicates

            describe '#code' do
              it { expect(subject.code).to eq('x < 5') }
            end
          end

          describe 'OpLessEq' do
            it { expect { OpLessEq[x] }.to raise_error }
            it { expect { OpLessEq[x, y, y] }.to raise_error }
            it { expect { OpLessEq[type, num] }.to raise_error }
            it { expect { OpLessEq[num, type] }.to raise_error }

            subject { OpLessEq[x, num] }
            let(:is_expr) { true }

            it_behaves_like :check_predicates

            describe '#code' do
              it { expect(subject.code).to eq('x <= 5') }
            end
          end
        end

      end
    end
  end
end
