module VersatileDiamond
  module Interpreter

    # Provides method which will catch all errors due incorrect relevant states
    module RelevantErrorsCatcher
      # @yield the procedure which can raise the error about relevant state of atom
      def catch_relevant_errors(spec, key, value, &block)
        block.call
      rescue Concepts::SpecificAtom::AlreadyUnfixed
        syntax_warning('specific_spec.atom_already_unfixed',
          spec: spec.name, atom: key)
      rescue Concepts::SpecificAtom::AlreadyStated
        syntax_error('specific_spec.atom_already_has_state',
          spec: spec.name, atom: key, state: value)
      end
    end

  end
end
