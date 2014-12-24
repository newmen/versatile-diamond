require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Unfixed do
      subject { unfixed }

      it_behaves_like :mono_instance_no_bond

      describe '#apply_to' do
        let(:atom) { SpecificAtom.new(c) }
        before { subject.apply_to(atom) }
        it { expect(atom.unfixed?).to be_truthy }
      end
    end

  end
end
