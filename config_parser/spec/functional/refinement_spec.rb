require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Refinement, type: :interpreter,
      reaction_refinements: true, reaction_properties: true do

      it_behaves_like "reaction refinemenets"

      it_behaves_like "reaction properties" do
        let(:target) { described_class.new(concept, {}) }
        let(:concept) { Tools::Chest.reaction('forward reaction name') }
        let(:reverse) { Tools::Chest.reaction('reverse reaction name') }
      end
    end

  end
end
