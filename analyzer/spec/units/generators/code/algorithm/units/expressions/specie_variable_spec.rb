require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe SpecieVariable, type: :algorithm do
          let(:dict) { VarsDictionary.new }
          let(:var) { dict.make_specie_s(subject) }

          describe '#define_arg' do
            include_context :unique_parent_context
            it { expect(var.define_arg.code).to eq('Bridge *bridge1') }
          end

          describe '#iterate_symmetries' do
            shared_examples_for :check_symmetries_iteration do
              let(:body) { Core::FunctionCall['hello'] }
              let(:inner_var) { dict.make_specie_s(subject, type: type) }
              let(:result) { var.iterate_symmetries([], inner_var, body) }
              it { expect(result.code).to eq(code.rstrip) }
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
