require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentWrappedSpec do
      describe '#initialize' do
        describe '#straighten_graph' do
          subject { described_class.new(bridge_base) }

          it { expect(subject.atoms_num).to eq(3) }
          it { expect(subject.relations_num).to eq(10) }

          # let(:positions) do
          #   all_relations.select { |_, relation| relation.position? }
          # end

          # it { expect(positions.size).to eq(2) }

        end
      end
    end

  end
end