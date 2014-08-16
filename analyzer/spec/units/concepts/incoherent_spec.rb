require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Incoherent do
      subject { incoherent }

      it_behaves_like :mono_instance_no_bond

      describe '#apply_to' do
        let(:atom) { SpecificAtom.new(cd) }
        before { subject.apply_to(atom) }
        it { expect(atom.incoherent?).to be_truthy }
      end
    end

  end
end
