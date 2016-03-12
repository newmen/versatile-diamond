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

          describe '#items' do
            it { expect(subject.items).to be_a(Array) }
            it { expect(subject.items[0]).to eq(var) }
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
        end

      end
    end
  end
end
