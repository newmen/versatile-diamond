require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Environment, type: :interpreter do
      let(:environment) { Environment.new(dimers_row) }

      describe "#targets" do
        before { environment.interpret('targets :one_atom, :two_atom') }
        it { dimers_row.is_target?(:one_atom).should be_true }
        it { dimers_row.is_target?(:two_atom).should be_true }
        it { dimers_row.is_target?(:wrong).should be_false }
      end

      describe "#aliases" do
        before(:each) { interpret_basis }
        it { expect { environment.interpret('aliases f: dimer, s: dimer') }.
          not_to raise_error }

        it { expect { environment.interpret('aliases one: wrong') }.
          to raise_error keyname_error }
      end

      describe "#where" do
        before(:each) do
          environment.interpret('where :end_row, "at end of dimers row"')
        end

        it { Tools::Chest.where(:dimers_row, :end_row).
          should be_a(Concepts::Where) }

        it { expect { environment.interpret('where :end_row, "some desc"') }.
          to raise_error keyname_error }
      end
    end

  end
end
