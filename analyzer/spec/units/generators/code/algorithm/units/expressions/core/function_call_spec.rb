require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe FunctionCall do
          let(:x) { Constant['x'] }
          let(:y) { Constant['y'] }
          let(:type) { Type['Yo'] }
          let(:num) { Constant[5] }
          let(:var) { Variable[namer, Object.new, type, 'obj'] }

          let(:namer) { Algorithm::Units::NameRemember.new }

          let(:simple) { described_class['simple'] }
          let(:mono) { described_class['mono', x] }
          let(:multi) { described_class['multi', x, y] }
          let(:templated) { described_class['templated', template_args: [type, num]] }
          let(:obj) { described_class['method', num, target: var] }

          describe '#self.[]' do
            it { expect(simple).to be_a(described_class) }
            it { expect(mono).to be_a(described_class) }
            it { expect(templated).to be_a(described_class) }
            it { expect(obj).to be_a(described_class) }

            describe 'side spaces' do
              it { expect { described_class[''] }.to raise_error }
              it { expect { described_class[' '] }.to raise_error }
              it { expect { described_class[' hello'] }.to raise_error }
              it { expect { described_class['world '] }.to raise_error }
            end

            describe 'wrong type' do
              it { expect { described_class[123] }.to raise_error }
              it { expect { described_class[2.71] }.to raise_error }
              it { expect { described_class[Object.new] }.to raise_error }
              it { expect { described_class[Array.new] }.to raise_error }
              it { expect { described_class[Hash.new] }.to raise_error }
              it { expect { described_class[Set.new] }.to raise_error }
              it { expect { described_class[type] }.to raise_error }
              it { expect { described_class[mono] }.to raise_error }
              it { expect { described_class[x] }.to raise_error }
            end

            describe 'invalid arguments' do
              it { expect { described_class[type] }.to raise_error }
              it { expect { described_class[template_args: [x]] }.to raise_error }
              it { expect { described_class[target: x] }.to raise_error }
            end
          end

          describe '#expr?' do
            it { expect(simple.expr?).to be_truthy }
          end

          describe '#var?' do
            it { expect(simple.var?).to be_falsey }
          end

          describe '#const?' do
            it { expect(simple.const?).to be_falsey }
          end

          describe '#type?' do
            it { expect(simple.type?).to be_falsey }
          end

          describe '#op?' do
            it { expect(simple.op?).to be_falsey }
          end

          describe '#code' do
            it { expect(simple.code).to eq('simple()') }
            it { expect(mono.code).to eq('mono(x)') }
            it { expect(multi.code).to eq('multi(x, y)') }
            it { expect(templated.code).to eq('templated<Yo, 5>()') }
            it { expect(obj.code).to eq('obj->method(5)') }
          end
        end

      end
    end
  end
end
