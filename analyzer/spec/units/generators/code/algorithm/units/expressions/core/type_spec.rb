require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        describe Type do
          include_context :predefined_exprs

          describe '#self.[]' do
            it { expect(type).to be_a(described_class) }

            it_behaves_like :check_expr_init

            describe 'wrong type' do
              it { expect { described_class[type] }.to raise_error }
            end
          end

          describe '#expr?' do
            it { expect(type.expr?).to be_falsey }
          end

          describe '#var?' do
            it { expect(type.var?).to be_falsey }
          end

          describe '#const?' do
            it { expect(type.const?).to be_truthy }
          end

          describe '#type?' do
            it { expect(type.type?).to be_truthy }
          end

          describe '#op?' do
            it { expect(type.op?).to be_falsey }
          end

          describe '#ptr' do
            it { expect(type.ptr.code).to eq('Yo *') }
          end

          describe '#member_ref' do
            it { expect(type.member_ref(func0.name).code).to eq('&Yo::simple') }
          end
        end

      end
    end
  end
end
