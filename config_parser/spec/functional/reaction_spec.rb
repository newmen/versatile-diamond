require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Reaction, type: :interpreter do
      describe "#equation" do
        it "error when spec name is undefined" do
          expect { reaction.interpret('equation * + hydrogen(h: *) = H') }.
            to raise_error *keyname_error(:undefined, :spec, :hydrogen)
        end

        describe "ubiquitous equation" do
          let(:concept) do
            Tools::Chest.ubiquitous_reaction('forward reaction name')
          end

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

          it "don't nest equation interpreter instance" do
            expect { reaction.interpret('  refinement "some"') }.
              to raise_error *syntax_error('common.wrong_hierarchy')
          end
        end

        describe "not ubiquitous equation" do
          let(:concept) { Tools::Chest.reaction('forward reaction name') }

          before(:each) { interpret_basis }

          it "not complience reactants" do
            expect { reaction.interpret(
                'equation bridge(cr: *) + bridge = bridge + bridge(ct: *)') }.
              to raise_error *syntax_error(
                'reaction.cannot_map', name: 'bridge')
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

            it "nest equation interpreter instance" do
              expect { reaction.interpret('  refinement "some"') }.
                not_to raise_error
            end

            describe "refinements" do
              it { expect { reaction.interpret('  incoherent bridge(:ct)') }.
                not_to raise_error }
              it { expect { reaction.interpret(
                  '  unfixed methyl_on_bridge(:cb)') }.
                not_to raise_error }
            end
          end

          describe "setup corresponding relevant state" do
            before(:each) do
              surface.interpret('spec :bridge_with_dimer')
              surface.interpret('  aliases dm: dimer')
              surface.interpret(
                '  atoms ct: C%d, cl: bridge(:ct), cr: dm(:cr), cf: dm(:cl)')
              surface.interpret('  bond :ct, :cl, face: 110, dir: :cross')
              surface.interpret('  bond :ct, :cr, face: 110, dir: :cross')

              reaction.interpret('aliases one: bridge, two: bridge')
              reaction.interpret('equation one(ct: *, ct: i) + two(cr: *) = bridge_with_dimer')
            end

            it { concept.products.first.atom(:cf).incoherent?.should be_true }
          end

          describe "incomplete bridge with dimer" do
            before(:each) do
              surface.interpret('spec :bridge_with_dimer')
              surface.interpret('  atoms cr: bridge(:cr), cf: bridge(:ct)')
              surface.interpret('  bond :cr, :cf, face: 100, dir: :front')

              reaction.interpret('aliases one: bridge, two: bridge')
              reaction.interpret(
                'equation one(ct: *, ct: i) + two(cr: *) = bridge_with_dimer')
            end

            it { concept.products.first.atom(:cf).incoherent?.should be_true }
          end

          describe "not initialy balanced reaction" do
            describe "extending product" do
              before(:each) do
                reaction.interpret('aliases source: bridge, product: bridge')
                reaction.interpret(
                  'equation high_bridge + source(ct: *) = product(cr: *)')
              end

              it { concept.source.first.external_bonds.should == 4 }
              it { concept.source.last.external_bonds.should == 3 }
              it { concept.products.first.external_bonds.should == 7 }
            end

            describe "extending first source and single product" do
              before(:each) do
                reaction.interpret('aliases source: dimer, product: dimer')
                reaction.interpret(
                  'equation methyl_on_bridge(cm: *) + source(cr: *) = product')
              end

              it { concept.source.first.external_bonds.should == 9 }
              it { concept.source.last.external_bonds.should == 5 }
              it { concept.products.first.external_bonds.should == 14 }
            end
          end

          describe "one to three" do
            before(:each) do
              reaction.interpret('aliases one: bridge, two: bridge')
            end

            it { expect { reaction.interpret(
                'equation dimer(cr: *) = high_bridge(cm: *) + one(ct: *) + two(ct: *)'
              ) }.not_to raise_error }
          end

          describe "reaction with wrong balance" do
            it { expect { reaction.interpret(
                'equation bridge(cr: *, cl: *) + methane(c: *) = methyl_on_bridge'
              ) }.to raise_error *syntax_error('reaction.wrong_balance') }
          end
        end
      end

      it_behaves_like "reaction properties" do
        let(:target) { reaction }
        let(:reverse) { Tools::Chest.reaction('reverse reaction name') }
      end

      describe "extended specs exchanges in names and specs" do
        before do
          interpret_basis
          reaction.interpret('aliases source: dimer, product: dimer')
          reaction.interpret(
            'equation methyl_on_bridge(cm: *, cm: u, cb: i) + source(cr: *) = product')
        end

        it { expect { reaction.interpret(
            '  position methyl_on_bridge(:cl), source(:cl), face: 100, dir: :cross'
          ) }.not_to raise_error }
      end
    end

  end
end
