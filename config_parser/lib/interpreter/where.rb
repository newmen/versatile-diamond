module VersatileDiamond
  module Interpreter

    # Interprets the where block and setups internal concept
    class Where < Component
      include AtomMatcher

      # Initialize an instance of interpreter by passed concepts
      # @param [Concepts::Where] environment the environment concept for
      #   checking positions
      # @param [Concepts::Where] where the internal concept which will be
      #   setuped
      # @param [Hash] names_and_specs the hash where each key is aliased name
      #   of spec and value is concrete spec
      def initialize(environment, where, names_and_specs)
        @env, @where = environment, where
        @names_and_specs = names_and_specs
        @used_spec_names = Set.new
      end

      # Interprets position line and setup internal concept for interpreting
      # result
      #
      # @param [Array] atom_strs the array of two elements one of which is
      #   represent a target atom from reactants and the second element is
      #   represent a environment spec atom
      # @param [Hash] options the options for creating position
      # @raise [Errors::SyntaxError] if some of atoms cannot be complienced or
      #   if spec in position cannot be resolved
      def position(*atom_strs, **options)
        target, atom = nil
        atom_strs.each do |atom_str|
          atom_sym = atom_str.to_sym
          if @env.is_target?(atom_sym)
            syntax_error('.cannot_link_targets') if target
            target = atom_sym
          else
            # TODO: maybe very strong validation?
            syntax_error('.should_links_with_target') if atom

            spec_name, keyname = match_used_atom(atom_str)
            spec = @names_and_specs[spec_name] || get(:spec, spec_name)
            atom = spec.atom(keyname)

            next if @used_spec_names.include?(spec_name)
            if atom
              @where.specs << spec
            else
              syntax_error('matcher.undefined_used_atom', name: atom_str)
            end

            @used_spec_names << spec_name
          end
        end

        @where.raw_position(target, atom, Concepts::Position[options])
      rescue Concepts::Position::IncompleteError
        syntax_error('position.uncomplete')
      end

      # Interprets use line and adds positions from used where to current where
      # @param [Array] names array of using wheres
      # @raise [Errors::SyntaxError] if using where already used or if using
      #   where cannot be resolved
      def use(*names)
        @used ||= Set.new
        names.each do |name|
          syntax_error('.already_use') if @used.include?(name)
          @used << name
          other = get(:where, @env.name, name)
          @where.adsorb(other)
        end
      end
    end

  end
end
