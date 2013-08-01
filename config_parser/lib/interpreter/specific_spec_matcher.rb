module VersatileDiamond
  module Interpreter

    # TODO: rspec
    # Module for matching specific spec from string
    module SpecificSpecMatcher

      # Detects the specified spec by matching spec name and specifing atoms
      # @param [String] specific_spec_str the analyzing specific spec string
      # @yield [String] provides a basic spec by it name
      # @return [Concepts::SpecificSpec] instance of specific spec
      def match_specific_spec(specified_spec_str, &block)
        name, args_str = Matcher.specified_spec(specified_spec_str)
        spec = block[name]

        specific_atoms = {}
        if args_str && args_str != ''
          extract_hash_args(args_str) do |key, value|
            atom = spec.atom(key)
            unless atom
              syntax_error('specific_spec.wrong_specification', atom: key)
            end

            specific_atom = specific_atoms[key] ||
              Concepts::SpecificAtom.new(atom)

            begin
              case value
              when 'i'
                specific_atom.incoherent!
              when 'u'
                specific_atom.unfixed!
              when /\A\*+\Z/
                value.scan('*').size.times do
                  specific_atom.active!
                end
              else syntax_error('specific_spec.wrong_specification', atom: key)
              end
            rescue Concepts::SpecificAtom::AlreadyStated
              syntax_error('specific_spec.atom_already_has_state',
                spec: name, atom: key, state: value)
            end

            specific_atoms[key] = specific_atom
          end
        end

        Concepts::SpecificSpec.new(spec, specific_atoms)
      rescue Concepts::Atom::IncorrectValence => e
        syntax_error('specific_spec.invalid_actives_num',
          spec: name, atom: e.atom)
      end
    end

  end
end
