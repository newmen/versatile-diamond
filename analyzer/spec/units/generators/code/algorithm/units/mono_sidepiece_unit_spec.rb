require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe MonoSidepieceUnit, type: :algorithm do
          include_context :methyl_adsorbtion_context

          before { subject.define! }

          subject { described_class.new(dict, node) }
          let(:dict) { Expressions::TargetCallsDictionary.new }
          let(:node) { entry_nodes.first }

          describe '#define!' do
            let(:var) { dict.var_of(node_specie) }
            it { expect(var.code).to eq('sidepiece') }
          end

          describe '#checkable?' do
            it { expect(subject.checkable?).to be_falsey }
          end
        end

      end
    end
  end
end
