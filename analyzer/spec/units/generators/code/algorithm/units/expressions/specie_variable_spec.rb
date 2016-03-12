require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe SpecieVariable, type: :algorithm do
          let(:namer) { Algorithm::Units::NameRemember.new }

          describe '#define_arg' do
            include_context :unique_parent_context
            let(:var) { described_class[namer, subject] }
            it { expect(var.define_arg.code).to eq('Bridge *bridge1') }
          end

          describe '#iterate_symmetries' do
            shared_examples_for :check_symmetries_iteration do
              let(:var) { described_class[namer, subject] }
              let(:body) { Core::FunctionCall['hello'] }
              let(:result) { var.iterate_symmetries(type, body) }

              it { expect(result.first).to be_a(described_class) }
              it { expect(result.first.instance).to eq(subject) }

              it { expect(result.last.code).to eq(code) }
            end

            describe 'unique parent' do
              include_context :unique_parent_context
              it_behaves_like :check_symmetries_iteration do
                let(:type) { ParentSpecieType[] }
                let(:code) do
                  <<-CODE
bridge1->eachSymmetry([](ParentSpec *bridge2) {
    hello();
})
                  CODE
                end
              end
            end

            describe 'unique reactant' do
              include_context :unique_reactant_context
              it_behaves_like :check_symmetries_iteration do
                let(:type) { ReactantSpecieType[] }
                let(:code) do
                  <<-CODE
methylOnBridge1->eachSymmetry([](SpecificSpec *methylOnBridge2) {
    hello();
})
                  CODE
                end
              end
            end
          end
        end

      end
    end
  end
end
