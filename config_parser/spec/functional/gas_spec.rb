require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Gas, type: :interpreter do
      describe "#spec" do
        it "interpreted spec stores in chest" do
          gas.interpret('spec :hello').should be_a(Interpreter::GasSpec)
          Tools::Chest.gas_spec(:hello).should be_a(Concepts::GasSpec)
        end
      end

      describe "#temperature" do
        it { expect { gas.interpret('temperature 100, C') }.
          not_to raise_error }
      end

      describe "#concentration" do
        let(:spec) { Spec.new(Tools::Chest.spec(:some)) }

        def define_spec_and_atom(valence)
          dimensions.interpret("concentration 'mol/cm3'")
          elements.interpret("atom Sm, valence: #{valence}")
          gas.interpret('spec some')
          spec.interpret('atoms x: Sm')
        end

        describe "defining a activated specific spec" do
          before(:each) { define_spec_and_atom(3) }
          it { expect { gas.interpret('concentration some(x: **), 1, "mol/l"') }.
            not_to raise_error }
          it { expect { gas.interpret('concentration some(x: **), 1') }.
            not_to raise_error }
        end

        describe "wrong defining a activated specific spec" do
          before(:each) { define_spec_and_atom(1) }
          it { expect { gas.interpret('concentration some(x: **), 1') }.
            to raise_error syntax_error }
        end

        describe "wrong defining a activated specific spec" do
          before(:each) { define_spec_and_atom(10) }
          it { expect { gas.interpret('concentration some(x: 2*), 1') }.
            to raise_error syntax_error }
          it { expect { gas.interpret('concentration some(x: *2), 1') }.
            to raise_error syntax_error }
        end

        describe "wrong atom keyname" do
          before(:each) { define_spec_and_atom(2) }
          it { expect { gas.interpret('concentration some(z: *), 1') }.
            to raise_error syntax_error }
        end

        describe "wrong name of specific spec" do
          before(:each) { define_spec_and_atom(2) }
          it { expect { gas.interpret('concentration wrong(x: *), 1') }.
            to raise_error syntax_error }
        end
      end
    end

  end
end
