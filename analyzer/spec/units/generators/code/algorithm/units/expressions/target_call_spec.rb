require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe TargetCall, type: :algorithm, use: :chunks do
          include_context :look_around_context
          include_context :small_activated_bridges_lateral_context

          subject { dict.make_target_s(target_species) }

          describe '#instance' do
            it { expect(subject.instance).to eq(first_ts) }
          end

          describe '#collection?' do
            it { expect(subject.collection?).to be_falsey }
          end

          describe '#item?' do
            it { expect(subject.item?).to be_falsey }
          end

          describe '#parent_arr?' do
            it { expect(subject.parent_arr?).to be_falsey }
          end

          describe '#iterate_symmetries' do
            let(:type) { SidepieceSpecieType[] }
            let(:inner_var) { dict.make_specie_s(target_species, type: type) }
            let(:body) { Core::FunctionCall['world'] }
            let(:result) { subject.iterate_symmetries([], inner_var, body) }
            let(:code) do
              <<-CODE
target()->eachSymmetry([](LateralSpec *bridgeCTs1) {
    world();
})
              CODE
            end
            it { expect(result.code).to eq(code.rstrip) }
          end

          describe '#atom_value' do
            let(:ct) { first_ts.spec.spec.atom(:ct) }
            it { expect(subject.atom_value(ct).code).to eq("target()->atom(0)") }
          end
        end

      end
    end
  end
end
