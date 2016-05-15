require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe TargetCall, type: :algorithm do
          include_context :unique_reactant_context

          let(:dict) { TargetCallsDictionary.new }
          let(:var) { dict.make_target_s(subject) }

          describe '#instance' do
            it { expect(var.instance).to eq(subject) }
          end

          describe '#iterate_symmetries' do
            let(:type) { SidepieceSpecieType[] }
            let(:inner_var) { dict.make_specie_s(subject, type: type) }
            let(:body) { Core::FunctionCall['world'] }
            let(:result) { var.iterate_symmetries([], inner_var, body) }
            let(:code) do
              <<-CODE
target()->eachSymmetry([](LateralSpec *methylOnBridge1) {
    world();
})
              CODE
            end
            it { expect(result.code).to eq(code.rstrip) }
          end

          describe '#atom_value' do
            it { expect(var.atom_value(cb).code).to eq("target()->atom(1)") }
          end
        end

      end
    end
  end
end
