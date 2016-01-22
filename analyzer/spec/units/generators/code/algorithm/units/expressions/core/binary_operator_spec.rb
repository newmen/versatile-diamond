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

            subject { OpCombine[x, num] }
            let(:is_tin) { true }

            it_behaves_like :check_predicates

            describe '#code' do
              it { expect(subject.code).to eq('x5') }
            end
          end

          describe 'LogicOperator' do
            shared_examples_for :check_chain_op do
              describe '#self.[]' do
                it { expect { op_class[type] }.to raise_error }
                it { expect { op_class[x, type] }.to raise_error }
              end

              subject { op_class[x] }
              let(:is_expr) { true }

              it_behaves_like :check_predicates

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
          end

          describe 'OpSequence' do
            subject { func_args_seq }

            it_behaves_like :check_predicates

            describe '#code' do
              it { expect(subject.code).to eq('obj, x, 5') }
              it { expect(tmpl_args_seq.code).to eq('Yo, 5') }
              it { expect(wrong_seq.code).to eq('x, Yo') }
            end
          end

          describe 'OpCall' do
            it { expect { OpCall[x] }.to raise_error }
            it { expect { OpCall[type] }.to raise_error }
            it { expect { OpCall[x, y] }.to raise_error }
            it { expect { OpCall[type, num] }.to raise_error }
            it { expect { OpCall[var, num] }.to raise_error }
            it { expect { OpCall[var, type] }.to raise_error }
            it { expect { OpCall[var, OpAnd[x, y]] }.to raise_error }

            subject { OpCall[var, OpCall[var, func2]] }
            let(:is_expr) { true }
            let(:is_op) { false }

            it_behaves_like :check_predicates

            describe '#code' do
              it { expect(subject.code).to eq('obj->obj->many(x, y)') }
              it { expect(OpCall[var, x].code).to eq('obj->x') }
              it { expect(OpCall[var, var].code).to eq('obj->obj') }
              it { expect(OpCall[var, tfunc0].code).to eq('obj->templ<Yo, 5>()') }
            end
          end

          describe 'OpNs' do
            it { expect { OpNs[x] }.to raise_error }
            it { expect { OpNs[type] }.to raise_error }
            it { expect { OpNs[x, y] }.to raise_error }
            it { expect { OpNs[num, y] }.to raise_error }
            it { expect { OpNs[var, x] }.to raise_error }
            it { expect { OpNs[type, num] }.to raise_error }
            it { expect { OpNs[type, OpOr[x, y]] }.to raise_error }

            subject { OpNs[type, func1] }
            let(:is_op) { false }

            it_behaves_like :check_predicates
            it_behaves_like :check_predicates do
              subject { OpNs[type, type] }
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
        end

      end
    end
  end
end
