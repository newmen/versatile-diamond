require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Where, type: :interpreter do
      let(:where) do
        described_class.new(dimers_row, at_end, { right: dimer_base })
      end

      describe "#position" do
        it { expect { where.interpret('position :one, right(:cr), face: 100, dir: :cross') }.
          not_to raise_error }
        it { expect { where.interpret('position right(:cr), :one, face: 100, dir: :cross') }.
          not_to raise_error }
        it { expect { where.interpret('position :one, :two, face: 100, dir: :front') }.
          to raise_error syntax_error }
        it { expect { where.interpret('position right(:cl), right(:cr), face: 100, dir: :front') }.
          to raise_error syntax_error }
        it { expect { where.interpret('position :one, right(:cr)') }.
          to raise_error syntax_error }
        it { expect { where.interpret('position :one, right(:wrong), face: 100, dir: :cross') }.
          to raise_error syntax_error }
        it { expect { where.interpret('position :one, wrong(:c), face: 100, dir: :cross') }.
          to raise_error keyname_error }
      end

      describe "#use" do
        describe "unresolved" do
          it { expect { where.interpret('use :wrong') }.
            to raise_error keyname_error }
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
              to raise_error syntax_error
          end
        end
      end
    end

  end
end
