module VersatileDiamond
  module Interpreter

    # Provides method for catch raised position errors
    module PositionErrorsCatcher
    private

      # Catches raised position errors and interprets it
      # @yield the action which could raise some position error
      def interpret_position_errors(&block)
        block.call
      rescue Concepts::Position::Incomplete
        syntax_error('position.incomplete')
      rescue Concepts::Position::Duplicate => e
        pos = e.position
        syntax_warning('position.duplicate', face: pos.face, dir: pos.dir)
      rescue Concepts::Position::UnspecifiedAtoms
        syntax_error('position.unspecified_atoms')
      end
    end

  end
end
