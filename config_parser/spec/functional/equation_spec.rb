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

      def make_env
        events.interpret('environment :some_env')
        events.interpret('  targets :one')
      end

      describe "#lateral" do
        before(:each) { make_env }

        describe "valid targets" do
          before(:each) do
            equation.interpret('lateral :some_env, one: mob(:cb)')
          end

          it { Tools::Chest.lateral('forward methyl desorption', :some_env).
            should be_a(Concepts::Lateral) }
          it { expect { equation.interpret('lateral :some_env, one: b(:ct)') }.
            to raise_error *keyname_error(:duplication, :lateral, :some_env) }
        end

        describe "invalid targets" do
          it { expect { equation.interpret('lateral :wrong_env') }.
            to raise_error *keyname_error(
              :undefined, :environment, :wrong_env) }

          it { expect { equation.interpret('lateral :some_env, wr: b(:ct)') }.
            to raise_error *syntax_error(
              'equation.undefined_target', name: 'wr') }

          it { expect { equation.interpret(
              'lateral :some_env, one: mob(:cb), wr: b(:ct)') }.
            to raise_error *syntax_error(
              'equation.undefined_target', name: 'wr') }

          it { expect { equation.interpret(
              'lateral :some_env, one: wrong(:ct)') }.
            to raise_error *syntax_error(
              'matcher.undefined_used_atom', name: 'wrong(:ct)') }

          it { expect { equation.interpret('lateral :some_env, one: b(:wr)') }.
            to raise_error *syntax_error(
              'matcher.undefined_used_atom', name: 'b(:wr)') }
        end
      end

      describe "#there" do
        before(:each) do
          make_env
          events.interpret('  where :some_where, "where tail"')
          equation.interpret('lateral :some_env, one: mob(:cb)')
        end

        it { expect { equation.interpret('there :wrong') }.
          to raise_error *keyname_error(:undefined, :there, :wrong) }

        it "make and get" do
          equation.interpret('there :some_where')
          Tools::Chest.lateral_reaction('forward methyl desorption where tail').
            should be_a(Concepts::LateralReaction)
        end
      end

      it_behaves_like "reaction refinemenets"
    end

  end
end
