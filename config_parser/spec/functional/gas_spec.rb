require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Gas do
      let(:gas) { Gas.new }

      describe "#spec" do
        it "interpreted spec stores in chest" do
          gas.interpret('spec :hello').should be_a(Interpreter::GasSpec)
          Tools::Chest.gas_spec(:hello).should be_a(Concepts::GasSpec)
        end
      end

      describe "#temperature" do
        it { -> { gas.interpret('temperature 100, C') }.
          should_not raise_error Exception }
      end

      describe "#concentration" do
        let(:dimensions) { Dimensions.new }
        let(:elements) { Elements.new }
        let(:spec) { Spec.new(Tools::Chest.spec(:some)) }

        def define_spec_and_atom(valence)
          dimensions.interpret("concentration 'mol/cm3'")
          elements.interpret("atom Sm, valence: #{valence}")
          gas.interpret('spec some')
          spec.interpret('atoms x: Sm')
        end

        it "defining a activated specific spec" do
          define_spec_and_atom(3)
          -> { gas.interpret('concentration some(x: **), 1, "mol/l"') }.
          should_not raise_error Exception
          -> { gas.interpret('concentration some(x: **), 1') }.
          should_not raise_error Exception
        end

        let(:syntax_error) { Errors::SyntaxError }
        let(:keyname_error) { Tools::Chest::KeyNameError }

        it "wrong defining a activated specific spec" do
          define_spec_and_atom(1)
          -> { gas.interpret('concentration some(x: **), 1') }.
          should raise_error syntax_error
        end

        it "wrong defining a activated specific spec" do
          define_spec_and_atom(10)
          -> { gas.interpret('concentration some(x: 2*), 1') }.
          should raise_error syntax_error
          -> { gas.interpret('concentration some(x: *2), 1') }.
          should raise_error syntax_error
        end

        it "wrong atom keyname" do
          define_spec_and_atom(2)
          -> { gas.interpret('concentration some(z: *), 1') }.
          should raise_error syntax_error
        end

        it "wrong name of specific spec" do
          define_spec_and_atom(2)
          -> { gas.interpret('concentration wrong(x: *), 1') }.
          should raise_error keyname_error
        end
      end
    end

  end
end
