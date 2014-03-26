require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Events, type: :interpreter do
      describe "#reaction" do
        before(:each) do
          interpret_basis
          events.interpret('reaction "reaction name"')
          events.interpret('  equation bridge(ct: *) + methane(c: *) = methyl_on_bridge')
        end

        it { expect(Tools::Chest.reaction('forward reaction name')).
          to be_a(Concepts::Reaction) }
      end

      describe "#environment" do
        before(:each) { events.interpret('environment "env name"') }
        it { expect(Tools::Chest.environment('env name')).
          to be_a(Concepts::Environment) }
      end
    end

  end
end
