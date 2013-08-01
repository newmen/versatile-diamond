require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Reaction do
      let(:elements) { Elements.new }
      let(:gas) { Gas.new }
      let(:surface) { Surface.new }
      let(:reaction) { Interpreter::Reaction.new('reaction name') }

      let(:syntax_error) { Errors::SyntaxError }
      let(:keyname_error) { Tools::Chest::KeyNameError }

      describe "#equation" do
        it "error when spec name is undefined" do
          -> { reaction.interpret('equation * + hydrogen(h: *) = H') }.
          should raise_error keyname_error
        end

        describe "ubiquitous eqautaion" do
          let(:concept) { Tools::Chest.ubiquitous_reaction('reaction name') }

          before(:each) do
            elements.interpret('atom H, valence: 1')
            gas.interpret('spec :hydrogen')
            gas.interpret('  atoms h: H')
            reaction.interpret('equation * + hydrogen(h: *) = H')
          end

          it { concept.class.should == Concepts::UbiquitousReaction }

          it "respects" do
            concept.source.one? { |s| s.class == Concepts::ActiveBond }.
              should be_true
            concept.source.one? { |s| s.class == Concepts::SpecificSpec }.
              should be_true
            concept.products.one? { |s| s.class == Concepts::AtomicSpec }.
              should be_true
          end

          it "not respects" do
            concept.products.one? { |s| s.class == Concepts::ActiveBond }.
              should be_false
            concept.products.one? { |s| s.class == Concepts::SpecificSpec }.
              should be_false
            concept.source.one? { |s| s.class == Concepts::AtomicSpec }.
              should be_false
          end
        end

        describe "not ubiquitous eqautaion" do
          let(:concept) { Tools::Chest.reaction('reaction name') }

          before(:each) do
            elements.interpret('atom C, valence: 4')
            gas.interpret('spec :methane')
            gas.interpret('  atoms c: C')
            surface.interpret('lattice :d, cpp_class: Diamond')
            surface.interpret('spec :bridge')
            surface.interpret('  atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)')
            surface.interpret('  bond :ct, :cl, face: 110, dir: front')
            surface.interpret('  bond :ct, :cr, face: 110, dir: front')
            surface.interpret('spec :methyl_on_bridge')
            surface.interpret('  atoms cb: bridge(:ct), cm: methane(:c)')
            surface.interpret('  bond :cb, :cm')
          end

          it "not comlience reactants" do
            -> { reaction.interpret('equation bridge(cr: *) + bridge = bridge + bridge(ct: *)') }.
              should raise_error syntax_error
          end

          describe "simple reaction" do
            before(:each) do
              reaction.interpret('equation bridge(ct: *) + methane(c: *) = methyl_on_bridge')
            end

            it { concept.class.should == Concepts::Reaction }

            it "all is specific spec" do
              concept.source.all? { |s| s.class == Concepts::SpecificSpec }.
                should be_true
              concept.products.all? { |s| s.class == Concepts::SpecificSpec }.
                should be_true
            end
          end

          describe "not balanced reaction" do
            before(:each) do
              surface.interpret('spec :high_bridge')
              surface.interpret('  aliases mob: methyl_on_bridge')
              surface.interpret('  atoms cb: mob(:cb), cm: mob(:cm)')
              surface.interpret('  bond :cb, :cm')
            end

            it "extending product" do
              reaction.interpret('aliases source: bridge, product: bridge')
              reaction.interpret('equation high_bridge + source(ct: *) = product(cr: *)')

              concept.source.first.external_bonds.should == 4
              concept.source.last.external_bonds.should == 3
              concept.products.first.external_bonds.should == 7
            end

            it "extending first source and single product" do
              surface.interpret('spec :dimer')
              surface.interpret('  atoms cl: bridge(:ct), cr: bridge(:ct)')
              surface.interpret('  bond :cl, :cr, face: 100, dir: front')
              reaction.interpret('aliases source: dimer, product: dimer')
              reaction.interpret('equation methyl_on_bridge(cm: *) + source(cr: *) = product')

              concept.source.first.external_bonds.should == 9
              concept.source.last.external_bonds.should == 5
              concept.products.first.external_bonds.should == 14
            end

          end

          describe "reaction with wrong balance" do
            it { -> { reaction.interpret('equation bridge(cr: *, cl: *) + methane(c: *) = methyl_on_bridge') }.
                should raise_error syntax_error }
          end
        end
      end
    end

  end
end
