require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe PositionErrorsCatcher, type: :interpreter do
      class Some < Component
        include PositionErrorsCatcher

        def raise_incomplete
          interpret_position_errors { raise Position::Incomplete }
        end

        def raise_duplicate
          interpret_position_errors do
            raise Position::Duplicate, Position[face: 100, dir: :front]
          end
        end
      end
      subject { Some.new }

      describe '#interpret_position_errors' do
        describe 'incomplete' do
          it { expect { subject.raise_incomplete }.
            to raise_error *syntax_error('position.incomplete') }
        end

        describe 'duplicate' do
          it { expect { subject.raise_duplicate}.
            to raise_error *syntax_warning(
              'position.duplicate', face: 100, dir: :front) }
        end
      end
    end

  end
end
