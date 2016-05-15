require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe ObjectType do
          subject { type }

          include_context :predefined_exprs
          let(:is_type) { true }

          it_behaves_like :check_predicates

          describe '#name' do
            it { expect(subject.name).to eq('Yo') }
          end

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
