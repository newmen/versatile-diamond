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
            it { expect { described_class[namer, [], type, 'xx'] }.to raise_error }
            it { expect { described_class[namer, :one, type, 'one'] }.to raise_error }
            it { expect { described_class[namer, [:o], type, 'o'] }.to raise_error }

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
            it { expect { mono_arr[0] }.to raise_error }

            it { expect(subject[0].code).to eq('manies1[0]') }
          end

          describe '#items' do
            it { expect(subject.items).to be_a(Array) }
            it { expect(subject.items[0]).to eq(subject[0]) }
          end

          describe '#code' do
            it { expect(subject.code).to eq('manies1') }
          end

          describe '#define_var' do
            it { expect(subject.define_var.code).to eq('Yo *manies1[2] = { x, y }') }
          end

          describe '#define_arg' do
            it { expect(subject.define_arg.code).to eq('Yo **manies1') }
          end

          describe '#call' do
            it { expect { subject.call('some') }.to raise_error }
          end
        end

      end
    end
  end
end
