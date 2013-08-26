require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe GasSpec do
      let(:spec) { GasSpec.new(:some_gas) }

      describe "#is_gas?" do
        it { spec.is_gas?.should be_true }
      end
    end

  end
end
