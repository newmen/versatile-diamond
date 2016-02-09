require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe ScalarType do
          subject { scalar }

          include_context :predefined_exprs
          let(:is_type) { true }
          let(:is_scalar) { true }

          describe '#self.[]' do
            it_behaves_like :check_expr_init
          end

          it_behaves_like :check_predicates

          describe '#ptr?' do
            it { expect(subject.ptr?).to be_falsey }
            it { expect(scalar.ptr.ptr?).to be_truthy }
          end

          describe '#ptr' do
            subject { scalar.ptr }
            it { expect(subject.code).to eq('int *') }
            it_behaves_like :check_predicates
          end
        end

      end
    end
  end
end
