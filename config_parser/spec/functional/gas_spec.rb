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
          not_to raise_error Exception }
      end

      describe "#concentration" do
        let(:spec) { Spec.new(Tools::Chest.spec(:some)) }

        def define_spec_and_atom(valence)
          dimensions.interpret("concentration 'mol/cm3'")
          elements.interpret("atom Sm, valence: #{valence}")
          gas.interpret('spec some')
          spec.interpret('atoms x: Sm')
        end

        it "defining a activated specific spec" do
          define_spec_and_atom(3)
          expect { gas.interpret('concentration some(x: **), 1, "mol/l"') }.
            not_to raise_error Exception
          expect { gas.interpret('concentration some(x: **), 1') }.
            not_to raise_error Exception
        end

        it "wrong defining a activated specific spec" do
          define_spec_and_atom(1)
          expect { gas.interpret('concentration some(x: **), 1') }.
            to raise_error syntax_error
        end

        it "wrong defining a activated specific spec" do
          define_spec_and_atom(10)
          expect { gas.interpret('concentration some(x: 2*), 1') }.
            to raise_error syntax_error
          expect { gas.interpret('concentration some(x: *2), 1') }.
            to raise_error syntax_error
        end

        it "wrong atom keyname" do
          define_spec_and_atom(2)
          expect { gas.interpret('concentration some(z: *), 1') }.
            to raise_error syntax_error
        end

        it "wrong name of specific spec" do
          define_spec_and_atom(2)
          expect { gas.interpret('concentration wrong(x: *), 1') }.
            to raise_error keyname_error
        end
      end
    end

  end
end
