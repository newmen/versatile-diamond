require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Type do
          subject { type }

          include_context :predefined_exprs
          let(:is_const) { true }
          let(:is_type) { true }

          describe '#self.[]' do
            it_behaves_like :check_expr_init
          end

          it_behaves_like :check_predicates

          describe '#ptr' do
            subject { type.ptr }
            let(:is_scalar) { true }
            it { expect(subject.code).to eq('Yo *') }
            it_behaves_like :check_predicates
          end

          describe '#member_ref' do
            it { expect(subject.member_ref(func0).code).to eq('&Yo::simple') }
          end
        end

      end
    end
  end
end
