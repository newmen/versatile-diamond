require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Equation, type: :interpreter, reaction_refinements: true do
      let(:equation) do
        described_class.new(methyl_desorption, md_names_to_specs)
      end

      describe "#refinement" do
        before { equation.interpret('refinement "from 111 face"') }
        it { expect {
          Tools::Chest.reaction('forward methyl desorption from 111 face')
          }.not_to raise_error
        }
      end

      it_behaves_like "reaction refinemenets"
    end

  end
end
