require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe UnaryOperator do
          include_context :predefined_exprs_for_ops

          describe 'ExpressionOperator' do
            let(:is_expr) { true }

            describe 'OpNot' do
              describe '#self.[]' do
                it { expect { OpNot[x, y] }.to raise_error }
                it { expect { OpNot[type] }.to raise_error }
                it { expect { OpNot[small_cond] }.to raise_error }
                it { expect { OpNot[func_args_seq] }.to raise_error }
              end

              subject { OpNot[x] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('!x') }
                it { expect(OpNot[func0].code).to eq('!simple()') }
              end
            end

            describe 'OpRef' do
              describe '#self.[]' do
                it { expect { OpRef[x, y] }.to raise_error }
                it { expect { OpRef[type] }.to raise_error }
                it { expect { OpRef[num] }.to raise_error }
                it { expect { OpRef[func0] }.to raise_error }
                it { expect { OpRef[small_cond] }.to raise_error }
                it { expect { OpRef[func_args_seq] }.to raise_error }
              end

              subject { OpRef[var] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('&obj') }
                it { expect(OpRef[].code).to eq('&') }
              end
            end

            describe 'OpRInc' do
              describe '#self.[]' do
                it { expect { OpRInc[x, y] }.to raise_error }
                it { expect { OpRInc[x] }.to raise_error }
                it { expect { OpRInc[type] }.to raise_error }
                it { expect { OpRInc[num] }.to raise_error }
                it { expect { OpRInc[func0] }.to raise_error }
                it { expect { OpRInc[small_cond] }.to raise_error }
                it { expect { OpRInc[func_args_seq] }.to raise_error }
              end

              subject { OpRInc[scv] }
              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('i++') }
              end
            end

            describe 'OpLInc' do
              subject { OpLInc[scv] }
              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('++i') }
              end
            end
          end

          describe 'OpBrakets' do
            describe 'OpAngleBks' do
              describe '#self.[]' do
                it { expect { OpAngleBks[type, num] }.to raise_error }
                it { expect { OpAngleBks[x] }.to raise_error }
                it { expect { OpAngleBks[func0] }.to raise_error }
                it { expect { OpAngleBks[small_cond] }.to raise_error }
                it { expect { OpAngleBks[func_args_seq] }.to raise_error }
                it { expect { OpAngleBks[wrong_seq] }.to raise_error }
              end

              subject { OpAngleBks[type] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('<Yo>') }
                it { expect(OpAngleBks[tmpl_args_seq].code).to eq('<Yo, 5>') }

                describe 'many long args' do
                  let(:long_name) { 'TooLongTypeName1234567890' }
                  let(:args) { [ObjectType[long_name]] * 2 }
                  let(:seq) { OpSequence[*args] }
                  let(:code) do
                    <<-CODE
<
    #{long_name},
    #{long_name}
>
                    CODE
                  end
                  it { expect(OpAngleBks[seq].code).to eq(code.rstrip) }
                end
              end
            end

            describe 'OpRoundBks' do
              describe '#self.[]' do
                it { expect { OpRoundBks[x, y] }.to raise_error }
                it { expect { OpRoundBks[type] }.to raise_error }
                it { expect { OpRoundBks[small_cond] }.to raise_error }
                it { expect { OpRoundBks[wrong_seq] }.to raise_error }
              end

              subject { OpRoundBks[x] }
              let(:is_expr) { true }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('(x)') }
                it { expect(OpRoundBks[func0].code).to eq('(simple())') }
                it { expect(OpRoundBks[func_args_seq].code).to eq('(obj, x, 5)') }
              end
            end

            describe 'OpSquireBks' do
              describe '#self.[]' do
                it { expect { OpSquireBks[x, y] }.to raise_error }
                it { expect { OpSquireBks[type] }.to raise_error }
                it { expect { OpSquireBks[small_cond] }.to raise_error }
                it { expect { OpSquireBks[wrong_seq] }.to raise_error }
              end

              subject { OpSquireBks[x] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('[x]') }
                it { expect(OpSquireBks[func0].code).to eq('[simple()]') }
                it { expect(OpSquireBks[func_args_seq].code).to eq('[obj, x, 5]') }
              end
            end

            describe 'OpBraces' do
              describe '#self.[]' do
                it { expect { OpBraces[x, y] }.to raise_error }
                it { expect { OpBraces[type] }.to raise_error }
              end

              describe '#code (and check predicates)' do
                describe 'one line' do
                  describe 'not external new lines' do
                    subject { OpBraces[x, multilines: false] }
                    let(:is_expr) { true }
                    it { expect(subject.code).to eq('{ x }') }

                    it_behaves_like :check_predicates
                  end

                  describe 'external new lines' do
                    subject { OpBraces[x, multilines: false, ext_new_lines: true] }
                    it { expect { subject }.to raise_error }
                  end
                end

                describe 'multilines' do
                  let(:code) do
                    <<-CODE
{
    x;
    y;
    many(x, y);
}
                    CODE
                  end
                  let(:many_lines) { code.rstrip }

                  describe 'not external new lines' do
                    subject { OpBraces[OpCombine[x, y, func2]] }
                    let(:lines) { " #{many_lines}" }
                    it { expect(subject.code).to eq(lines) }

                    it_behaves_like :check_predicates
                  end

                  describe 'external new lines' do
                    subject { OpBraces[OpCombine[x, y, func2], ext_new_lines: true] }
                    let(:lines) { "\n#{many_lines}\n" }
                    it { expect(subject.code).to eq(lines) }

                    it_behaves_like :check_predicates
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end
