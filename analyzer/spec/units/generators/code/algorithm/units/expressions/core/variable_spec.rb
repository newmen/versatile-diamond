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

          describe '#update_index!' do
            let(:new_index) { Constant[22] }
            before { item1.update_index!(new_index) }
            it { expect(item1.code).to eq('items[22]') }
            it { expect { subject.update_index!(new_index) }.to raise_error }
          end

          describe '#instance' do
            it { expect(subject.instance).to eq(:var) }
          end

          describe '#type' do
            it { expect(subject.type).to eq(type.ptr) }
          end

          describe '#code' do
            it { expect(subject.code).to eq('obj') }
            it { expect { described_class[:v, type].code }.to raise_error }
          end

          describe '#define_var' do
            it { expect(subject.define_var.code).to eq('Yo *obj') }
            it { expect(vvl.define_var.code).to eq('Yo *val = simple()') }

            describe 'constructor' do
              it { expect(inst.define_var(x, y).code).to eq('Yo inst(x, y)') }
            end
          end

          describe '#define_arg' do
            it { expect(subject.define_arg.code).to eq('Yo *obj') }
            it { expect(vvl.define_arg.code).to eq('Yo *val') }
          end

          describe '#call' do
            it { expect(method.code).to eq('obj->foo(x, x)') }
            it { expect(vvl.call('bar').code).to eq('val->bar()') }
          end

          describe '#member' do
            it { expect(vvl.member('bar').code).to eq('val.bar()') }
          end

          describe '#item?' do
            it { expect(subject.item?).to be_falsey }
            it { expect(many_arr.items.first.item?).to be_truthy }
          end

          describe '#obj?' do
            it { expect(subject.obj?).to be_truthy }
            it { expect(scv.obj?).to be_falsey }
          end

          describe '#collection?' do
            it { expect(subject.collection?).to be_falsey }
          end

          describe '#proxy?' do
            it { expect(subject.proxy?).to be_falsey }
          end
        end

      end
    end
  end
end
