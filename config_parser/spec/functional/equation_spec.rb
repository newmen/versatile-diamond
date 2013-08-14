require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Equation do
      let(:names_to_specs) do {
        source: { mob: methyl_on_bridge },
        products: { m: methyl, ab: activated_bridge }
      } end
      let(:equation) { described_class.new(reaction, names_to_specs) }

      describe "#refinement" do
        before { equation.interpret('refinement "from 111 face"') }

      end
    end

  end
end
