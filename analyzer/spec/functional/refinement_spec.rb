require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Refinement, type: :interpreter do

      it_behaves_like :reaction_refinemenets

      it_behaves_like :reaction_properties do
        let(:target) { described_class.new(concept, {}) }
        let(:concept) { Tools::Chest.reaction('forward reaction name') }
        let(:reverse) { Tools::Chest.reaction('reverse reaction name') }
      end
    end

  end
end
