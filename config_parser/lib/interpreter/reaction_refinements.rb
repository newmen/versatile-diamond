module VersatileDiamond
  module Interpreter

    # Interprets reaction refinements and pass it to concept instances
    module ReactionRefinements
      include Interpreter::AtomMatcher

      # Defines two methods for setup an instance of specific spec which found
      # specs set by spec name
      %w(incoherent unfixed).each do |state|
        # Setup of state provides for concrete atom by keyname
        # @param [Array] used_atom_strs the array of string where each string
        #   matched for atom used in specific spec
        # @raise [Errors::SyntaxError] if setuped atom already has setuping
        #   state
        define_method(state) do |*used_atom_strs|
          begin
            used_atom_strs.each do |atom_str|
              find_spec(atom_str, :all) do |specific_spec, atom_keyname|
                specific_spec.send(:"#{state}!", atom_keyname)
              end
            end
          rescue Concepts::SpecificAtom::AlreadyStated => e
            syntax_error('specific_spec.atom_already_has_state',
              state: e.state)
          end
        end
      end

      # Sets the position of atoms relative to each other for the current
      # reaction concept
      #
      # @param [Array] used_atom_strs the array of string where each string
      #   matched for atom used in specific spec
      # @param [Hash] options the options of position
      # @raise [Errors::SyntaxError] if position already exists for selected
      #   atoms or atom cannot be found
      def position(*used_atom_strs, **options)
        first_atom, second_atom = used_atom_strs.map do |atom_str|
          find_spec(atom_str) do |specific_spec, atom_keyname|
            specific_spec.atom(atom_keyname)
          end
        end

        pos = Concepts::Position[options]
        if @reaction.positions &&
          @reaction.positions.find do |f, s, p|
            (f == first_atom && s = second_atom) ||
              (s == first_atom && f = second_atom)
          end

          syntax_error('refinement.duplicate_position')
        end

        @reaction.positions << [first_atom, second_atom, pos]
      rescue Concepts::Position::IncompleteError
        syntax_error('position.uncomplete')
      end

    private

      # Finds specific spec in names to specs hash
      # @param [String] used_atom_str the parsing string
      # @param [Symbol] find_type the type of search algorithm, can be
      #   :any or :all
      # @yield [Concepts::SpecificSpec, Symbol] do for each found spec
      # @raise [Errors::SyntaxError] if specific spec is not found or have
      #   inaccurate compliance
      def find_spec(used_atom_str, find_type = :any, &block)
        spec_name, atom_keyname = match_used_atom(used_atom_str)
        spec_name = spec_name.to_sym
        find_lambda = -> type do
          result = @names_and_specs[type].select do |name, _|
            name.to_sym == spec_name
          end
          if result.size > 1
            syntax_error('refinement.cannot_compliance', name: spec_name)
          end
          result.first && result.first.last
        end

        if find_type == :any
          specific_spec = find_lambda[:source] || find_lambda[:products]
          unless specific_spec && specific_spec.atom(atom_keyname)
            syntax_error('matcher.undefined_used_atom', name: used_atom_str)
          end

          block[specific_spec, atom_keyname]
        elsif find_type == :all
          specific_specs = [
            find_lambda[:source], find_lambda[:products]].compact
          if specific_specs.empty? ||
            specific_specs.find { |s| !s.atom(atom_keyname) }

            syntax_error('matcher.undefined_used_atom', name: used_atom_str)
          end

          specific_specs.each { |ss| block[ss, atom_keyname] }
        else
          raise ArgumentError, "Undefined find type #{find_type}"
        end
      end

    end

  end
end
