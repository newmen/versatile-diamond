require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe UnaryOperator do
          include_context :predefined_exprs_for_ops

          describe 'PrefixOperator' do
            let(:is_expr) { true }

            describe 'OpNot' do
              describe '#self.[]' do
                it { expect { OpNot[x, y] }.to raise_error }
                it { expect { OpNot[type] }.to raise_error }
              end

              subject { OpNot[x] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('!x') }
                it { expect(OpNot[func0].code).to eq('!simple()') }
                it { expect(OpNot[method].code).to eq('!obj->method(5)') }
              end
            end

            describe 'OpRef' do
              describe '#self.[]' do
                it { expect { OpRef[x, y] }.to raise_error }
                it { expect { OpRef[type] }.to raise_error }
                it { expect { OpRef[func0] }.to raise_error }
                it { expect { OpRef[method] }.to raise_error }
              end

              subject { OpRef[x] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('&x') }
              end
            end
          end

          describe 'OpBrakets' do
            describe 'OpAngleBks' do
              describe '#self.[]' do
                it { expect { OpAngleBks[type, num] }.to raise_error }
                it { expect { OpAngleBks[x] }.to raise_error }
                it { expect { OpAngleBks[func0] }.to raise_error }
                it { expect { OpAngleBks[method] }.to raise_error }
                it { expect { OpAngleBks[OpCombine[type, num]] }.to raise_error }
                it { expect { OpAngleBks[OpSequence[type, y]] }.to raise_error }
              end

              subject { OpAngleBks[type] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('<Yo>') }
                it { expect(OpAngleBks[OpSequence[type, num]].code).to eq('<Yo, 5>') }
              end
            end

            describe 'OpRoundBks' do
              describe '#self.[]' do
                it { expect { OpRoundBks[x, y] }.to raise_error }
                it { expect { OpRoundBks[type] }.to raise_error }
                it { expect { OpRoundBks[OpSequence[x, type]] }.to raise_error }
              end

              subject { OpRoundBks[x] }
              let(:is_expr) { true }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('(x)') }
                it { expect(OpRoundBks[func0].code).to eq('(simple())') }
                it { expect(OpRoundBks[method].code).to eq('(obj->method(5))') }
                it { expect(OpRoundBks[OpSequence[x, y]].code).to eq('(x, y)') }
              end
            end

            describe 'OpSquireBks' do
              describe '#self.[]' do
                it { expect { OpSquireBks[x, y] }.to raise_error }
                it { expect { OpSquireBks[type] }.to raise_error }
                it { expect { OpSquireBks[OpSequence[x, type]] }.to raise_error }
              end

              subject { OpSquireBks[x] }

              it_behaves_like :check_predicates

              describe '#code' do
                it { expect(subject.code).to eq('[x]') }
                it { expect(OpSquireBks[func0].code).to eq('[simple()]') }
                it { expect(OpSquireBks[method].code).to eq('[obj->method(5)]') }
                it { expect(OpSquireBks[OpSequence[x, y]].code).to eq('[x, y]') }
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
                  let(:many_lines) { "{\n    x;\n    y;\n    many(x, y);\n}" }

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
