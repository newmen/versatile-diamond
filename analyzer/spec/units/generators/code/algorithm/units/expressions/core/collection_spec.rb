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
            it { expect(subject).to be_a(described_class) }
            it { expect(mono_arr).to be_a(described_class) }

            describe 'wrong number of values' do
              let(:wrong_arr) { described_class[namer, [:a, :b], type, 'nm', ['v']] }
              it { expect { wrong_arr }.to raise_error }
            end
          end

          it_behaves_like :check_predicates

          describe '#[]' do
            it { expect(subject[0]).to be_a(Variable) }
            it { expect(subject[1]).to be_a(Variable) }
            it { expect { subject[2] }.to raise_error }
          end

          describe '#code' do
            it { expect(subject.code).to eq('manies1') }
            it { expect(mono_arr.code).to eq('mono1') }
          end

          describe '#define_var' do
            it { expect(subject.define_var.code).to eq('Yo *manies1[2] = { x, y }') }
            it { expect(mono_arr.define_var.code).to eq('Yo *mono1 = mono(x)') }
          end

          describe '#define_arg' do
            it { expect(subject.define_arg.code).to eq('Yo **manies1') }
            it { expect(mono_arr.define_arg.code).to eq('Yo *mono1') }
          end

          describe '#call' do
            it { expect { subject.call('some') }.to raise_error }
            it { expect(mono_arr.call('some').code).to eq('mono1->some()') }
          end
        end

      end
    end
  end
end
