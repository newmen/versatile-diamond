module VersatileDiamond
  module Interpreter

    # Interprets reaction refinements and pass it to concept instances
    module ReactionRefinements
      include Interpreter::AtomMatcher
      include Interpreter::PositionErrorsCatcher
      include Interpreter::RelevantErrorsCatcher

      # Defines two methods for setup an instance of specific spec which found
      # specs by spec name
      %w(incoherent unfixed).each do |state|
        # Setup of state provides for concrete atom by keyname
        # @param [Array] used_atom_strs the array of string where each string
        #   matched for one atom used in specific spec
        define_method(state) do |*used_atom_strs|
          used_atom_strs.each do |atom_str|
            find_all_specs(atom_str) do |specific_spec, atom_keyname|
              catch_relevant_errors(specific_spec, atom_keyname, state) do
                old_atom = specific_spec.atom(atom_keyname)
                unless old_atom.send(:"#{state}?")
                  specific_spec.send(:"#{state}!", atom_keyname)
                end
                new_atom = specific_spec.atom(atom_keyname)

                @reaction.apply_relevants(specific_spec, old_atom, new_atom)
              end
            end
          end
        end
      end

      # Sets the position of atoms relative to each other for the current
      # reaction concept
      #
      # @param [Array] used_atom_strs see at #position_by same argument
      # @param [Hash] options see at #position_by same argument
      def position(*used_atom_strs, **options)
        position_by(Concepts::Position, *used_atom_strs, **options)
      end

      # Sets no position of atoms relative to each other for the current
      # reaction concept
      #
      # @param [Array] used_atom_strs see at #position_by same argument
      # @param [Hash] options see at #position_by same argument
      define_method(:'no-position') do |*used_atom_strs, **options|
        position_by(Concepts::NonPosition, *used_atom_strs, **options)
      end

    private

      # Sets the position relation between atoms
      # @param [Class] klass of position relation
      # @param [Array] used_atom_strs the array of string where each string
      #   matched for atom used in specific spec
      # @param [Hash] options the options of position
      # @raise [Errors::SyntaxError] if position already exists for selected
      #   atoms or atom cannot be found
      def position_by(klass, *used_atom_strs, **options)
        first_spec_atom, second_spec_atom =
          used_atom_strs.map do |atom_str|
            specific_spec, atom_keyname = find_any_spec(atom_str)
            [specific_spec, specific_spec.atom(atom_keyname)]
          end

        first_spec, _ = first_spec_atom
        second_spec, _ = second_spec_atom
        current = current_reaction(first_spec, second_spec)

        interpret_position_errors do
          pos = klass[options]
          current.position_between(first_spec_atom, second_spec_atom, pos)
        end
      end

      # Gets current reaction by passed species
      # @param [Array] specs the array of species which should be the source
      #   species for resulting reation
      # @param [Reaction] the reaction where passed species are source species
      def current_reaction(*specs)
        specs = specs.uniq

        if specs.all? { |spec| @reaction.source.include?(spec) }
          @reaction
        elsif specs.all? { |spec| @reaction.products.include?(spec) }
          @reaction.reverse
        else
          syntax_error('refinement.different_parts')
        end
      end

      # Finds any specific spec in names to specs hash
      # @param [String] used_atom_str the parsing string
      # @raise [Errors::SyntaxError] if specific spec is not found or have
      #   inaccurate compliance
      # @return [SpecificSpec, Symbol] the array where first element is found
      #   spec and second is used atom keyname
      def find_any_spec(used_atom_str)
        spec_name, atom_keyname = match_used_atom(used_atom_str)
        spec_name = spec_name.to_sym

        specific_spec = find_spec_in(:source, spec_name) ||
          find_spec_in(:products, spec_name)

        unless specific_spec && specific_spec.atom(atom_keyname)
          syntax_error('matcher.undefined_used_atom', name: used_atom_str)
        end

        [specific_spec, atom_keyname]
      end

      # Finds all specific specs in names to specs hash and do for it passed
      # block
      #
      # @param [String] used_atom_str the parsing string
      # @yield [Concepts::SpecificSpec, Symbol] do for each found spec
      # @raise [Errors::SyntaxError] if specific spec is not found or have
      #   inaccurate compliance
      def find_all_specs(used_atom_str, &block)
        spec_name, atom_keyname = match_used_atom(used_atom_str)
        spec_name = spec_name.to_sym

        specific_specs = [
          find_spec_in(:source, spec_name),
          find_spec_in(:products, spec_name)].compact

        if specific_specs.empty? ||
          specific_specs.find { |s| !s.atom(atom_keyname) }

          syntax_error('matcher.undefined_used_atom', name: used_atom_str)
        end

        specific_specs.each { |ss| block[ss, atom_keyname] }
      end

      # Finds spec in some part of equation
      # @param [Symbol] type the equation part
      # @param [Symbol] spec_name the name of found spec
      # @return [SpecificSpec] nil or found specific spec
      def find_spec_in(type, spec_name)
        result = @names_and_specs[type].select do |name, _|
          name.to_sym == spec_name
        end
        if result.size > 1
          syntax_error('refinement.cannot_compliance', name: spec_name)
        end

        # gets the spec
        result.first && result.first.last
      end

    end

  end
end
