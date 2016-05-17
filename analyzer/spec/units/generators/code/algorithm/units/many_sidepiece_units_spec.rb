require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe ManySidepieceUnits, type: :algorithm do
          include_context :dimer_formation_context

          def nodes_to_mono_units(nodes)
            nodes.map { |node| MonoSidepieceUnit.new(dict, node) }
          end

          def nodes_to_many_units(nodes)
            described_class.new(dict, nodes_to_mono_units(nodes))
          end

          before { subject.define! }

          subject { nodes_to_many_units(entry_nodes + nbr_nodes) }
          let(:dict) { Expressions::TargetCallsDictionary.new }

          describe '#define!' do
            it { expect(dict.var_of(node_specie).code).to eq('sidepieces[0]') }
            it { expect(dict.var_of(nbr_species.first).code).to eq('sidepieces[1]') }
          end

          describe '#checkable?' do
            it { expect(subject.checkable?).to be_falsey }
          end
        end

      end
    end
  end
end
