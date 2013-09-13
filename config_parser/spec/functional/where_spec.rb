require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Where, type: :interpreter do
      let(:concept) { Concepts::Where.new(:concept, 'description') }
      let(:where) do
        described_class.new(dimers_row, concept, { right: dimer_base, left: dimer_base })
      end

      describe "#position" do
        it { expect { where.interpret('position :one, right(:cr), face: 100, dir: :cross') }.
          not_to raise_error }
        it { expect { where.interpret('position right(:cr), :one, face: 100, dir: :cross') }.
          not_to raise_error }
        it { expect { where.interpret('position :one, :two, face: 100, dir: :front') }.
          to raise_error syntax_error('where.cannot_link_targets') }
        it { expect { where.interpret('position right(:cl), right(:cr), face: 100, dir: :front') }.
          to raise_error syntax_error('where.should_links_with_target') }
        it { expect { where.interpret('position :one, right(:cr)') }.
          to raise_error syntax_error('position.uncomplete') }
        it { expect { where.interpret('position :one, right(:wrong), face: 100, dir: :cross') }.
          to raise_error syntax_error('matcher.undefined_used_atom', name: 'right(:wrong)') }
        it { expect { where.interpret('position :one, wrong(:c), face: 100, dir: :cross') }.
          to raise_error keyname_error(:undefined, :spec, :wrong) }

        describe "spec are not twise storable" do
          before do
            where.interpret('position :one, right(:cr), face: 100, dir: :cross')
            where.interpret('position :two, right(:cl), face: 100, dir: :cross')
          end
          it { concept.specs.should == [dimer_base] }
        end
      end

      describe "#use" do
        describe "unresolved" do
          it { expect { where.interpret('use :not_important') }.
            to raise_error keyname_error(:undefined, :where, :where) }
        end

        describe "resolved" do
          before(:each) do
            events.interpret('environment :dimers_row')
            events.interpret('  where :using_where, "desc"')
          end

          it { expect { where.interpret('use :using_where') }.
            not_to raise_error }

          it "twise using" do
            where.interpret('use :using_where')
            expect { where.interpret('use :using_where') }.
              to raise_error syntax_error('where.already_use', name: :using_where)
          end
        end

        describe "spec are twise storable" do
          before do
            where.interpret('position :one, left(:cr), face: 100, dir: :cross')
            where.interpret('position :two, left(:cl), face: 100, dir: :cross')
            where.interpret('position :one, right(:cr), face: 100, dir: :cross')
            where.interpret('position :two, right(:cl), face: 100, dir: :cross')
          end
          it { concept.specs.should == [dimer_base, dimer_base] }
        end
      end
    end

  end
end
