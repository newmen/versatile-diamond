require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe This do
          subject { described_class[] }

          include_context :predefined_exprs
          it_behaves_like :check_predicates
          let(:is_expr) { true }

          describe '#code' do
            it { expect(subject.code).to eq('this') }
          end
        end

      end
    end
  end
end
