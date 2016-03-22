require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Constant do
          subject { enum }

          include_context :predefined_exprs
          let(:is_expr) { true }
          let(:is_const) { true }

          describe '#self.[]' do
            it_behaves_like :check_const_init

            describe 'wrong type' do
              it { expect { described_class[123] }.not_to raise_error }
              it { expect { described_class[2.71] }.not_to raise_error }
            end
          end

          it_behaves_like :check_predicates
          it_behaves_like :check_predicates do
            subject { num }
          end

          describe 'not realy consts' do
            let(:is_const) { false }

            it_behaves_like :check_predicates do
              subject { x }
            end

            it_behaves_like :check_predicates do
              subject { empty_cn }
            end
          end

          describe '#code' do
            it { expect(subject.code).to eq('VALUE_3') }
            it { expect(num.code).to eq('5') }
          end
        end

      end
    end
  end
end
