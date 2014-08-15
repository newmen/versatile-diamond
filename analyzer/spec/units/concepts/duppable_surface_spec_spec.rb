require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe DuppableSurfaceSpec do
      describe '#dup' do
        before { bridge_base_dup.rename_atom(:t, :YY) }

        it { expect(bridge_base.atom(:YY)).to be_nil }
        it { expect(bridge_base_dup.atom(:YY)).not_to be_nil }
      end
    end

  end
end
