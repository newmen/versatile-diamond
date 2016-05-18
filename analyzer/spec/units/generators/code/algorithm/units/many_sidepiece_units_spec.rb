require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ManySidepieceUnits, type: :algorithm, use: :chunks do
          include_context :check_laterals_context
          include_context :end_dimer_formation_lateral_context

          def nodes_to_mono_units(nodes)
            nodes.map { |node| MonoSidepieceUnit.new(dict, node) }
          end

          def nodes_to_many_units(nodes)
            described_class.new(dict, nodes_to_mono_units(nodes))
          end

          before { subject.define! }

          subject { nodes_to_many_units(entry_nodes) }
          let(:spec) { lateral_dimer }

          describe '#define!' do
            it { expect(dict.var_of(target_species).code).to eq('sidepiece') }
          end

          describe '#checkable?' do
            it { expect(subject.checkable?).to be_falsey }
          end
        end

      end
    end
  end
end
