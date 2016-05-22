require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ActionTargetUnit, type: :algorithm do
          include_context :look_around_context

          let(:pure_factory) { Algorithm::LookAroundPureUnitsFactory.new(dict) }
          let(:pure_unit) { pure_factory.unit(action_nodes) }
          let(:context) { LateralContextProvider.new(dict, backbone.big_graph, []) }
          subject { described_class.new(context, pure_unit) }

          let(:return100) do
            -> { Expressions::Core::Return[Expressions::Core::Constant[100]] }
          end

          describe '#predefine!' do
            let(:result) { subject.predefine!(&return100) }

            describe 'lateral dimer formation' do
              include_context :end_dimer_formation_lateral_context
              let(:code) do
                <<-CODE
Atom *atoms1[2] = { target(0)->atom(0), target(1)->atom(0) };
return 100;
                CODE
              end
              it { expect(result.code).to eq(code.rstrip) }
            end

            describe 'many similar activated bridges' do
              include_context :small_activated_bridges_lateral_context
              let(:code) do
                <<-CODE
Atom *atoms1[2] = { target(0)->atom(0), target(1)->atom(0) };
for (uint a = 0; a < 2; ++a)
{
    return 100;
}
                CODE
              end
              it { expect(result.code).to eq(code.rstrip) }
            end
          end
        end

      end
    end
  end
end
