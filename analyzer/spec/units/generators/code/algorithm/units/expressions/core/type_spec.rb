require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Type do
          include_context :predefined_exprs
          let(:is_const) { true }
          let(:is_type) { true }

          describe '#self.[]' do
            it { expect(type).to be_a(described_class) }

            it_behaves_like :check_expr_init

            describe 'wrong type' do
              it { expect { described_class[type] }.to raise_error }
            end
          end

          it_behaves_like :check_predicates do
            subject { type }
          end

          describe '#ptr' do
            it { expect(type.ptr.code).to eq('Yo *') }
            it_behaves_like :check_predicates do
              subject { type.ptr }
            end
          end

          describe '#member_ref' do
            it { expect(type.member_ref(func0).code).to eq('&Yo::simple') }
          end
        end

      end
    end
  end
end
