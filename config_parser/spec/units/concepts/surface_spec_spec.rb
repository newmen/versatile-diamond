require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe SurfaceSpec do
      let(:spec) { SurfaceSpec.new(:some_surface) }

      describe "#is_gas?" do
        it { spec.is_gas?.should be_false }
      end
    end

  end
end
