require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Collection do
          subject { many_arr }

          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_var) { true }

          describe '#self.[]' do
            it { expect { described_class[[], type, 'xx'] }.to raise_error }
            it { expect { described_class[:one, type, 'one'] }.to raise_error }
            it { expect { described_class[[var], type, 'o'] }.to raise_error }

            describe 'wrong number of values' do
              let(:wrong_arr) { described_class[[var, vvl], type, 'nm', ['v']] }
              it { expect { wrong_arr }.to raise_error }
            end
          end

          it_behaves_like :check_predicates

          let(:return31) do
            -> do
              value = Algorithm::Units::Expressions::Core::Constant[31]
              Algorithm::Units::Expressions::Core::Return[value]
            end
          end

          describe '#type' do
            it { expect(subject.type).to eq(type.ptr) }
          end

          describe '#items' do
            it { expect(subject.items).to eq([item1, item2]) }
          end

          describe '#code' do
            it { expect(subject.code).to eq('many') }
          end

          describe '#define_var' do
            it { expect(subject.define_var.code).to eq('Yo *many[2] = { x, y }') }
          end

          describe '#define_arg' do
            it { expect(subject.define_arg.code).to eq('Yo **many') }
          end

          describe '#call' do
            it { expect { subject.call('some') }.to raise_error }
          end

          describe '#member' do
            it { expect { subject.member('some') }.to raise_error }
          end

          describe '#item?' do
            it { expect(subject.item?).to be_falsey }
          end

          describe '#collection?' do
            it { expect(subject.collection?).to be_truthy }
          end

          describe '#parent_arr?' do
            it { expect(subject.parent_arr?(var)).to be_falsey }
            it { expect(subject.parent_arr?(item1)).to be_truthy }
          end

          describe '#iterate' do
            let(:code) do
              <<-CODE
for (uint x = 0; x < 2; ++x)
{
    return 31;
}
              CODE
            end
            let(:dict) { Algorithm::Units::Expressions::VarsDictionary.new }
            let(:result) { subject.iterate(dict.make_iterator(:x), return31.call) }
            it { expect(result.code).to eq(code) }
          end
        end

      end
    end
  end
end
