module VersatileDiamond
  module Interpreter

    # Module for matching specific spec from string
    module SpecificSpecMatcher

      # Detects the specified spec by matching spec name and specifing atoms
      # @param [String] specific_spec_str the analyzing specific spec string
      # @yield [String] provides a basic spec by it name
      # @raise [Errors::SyntaxError] if one of specified atom has incorrect
      #   valence
      # @return [Concepts::SpecificSpec] instance of specific spec
      def match_specific_spec(specified_spec_str, &block)
        name, args_str = Matcher.specified_spec(specified_spec_str)

        spec = block[name]
        atoms = match_specific_atoms(spec, args_str)

        Concepts::SpecificSpec.new(spec, atoms)
      rescue Concepts::Atom::IncorrectValence => e
        syntax_error('specific_spec.atom_invalid_bonds_num',
          spec: name, atom: e.atom)
      end

    private

      # Matches specific atoms from passed string
      # @param [Concepts::Spec] spec for which atoms is specified herein
      # @param [String] args_str the string which contain atoms configuration
      #   of some specie and which will be parsed
      # @raise [Errors::SyntaxError] if wrong specification detected
      # @return [Hash] the hash where keys is keys used in passed string and
      #   values is specific atoms correspondly setuped
      def match_specific_atoms(spec, args_str)
        specific_atoms = {}
        if args_str && args_str != ''
          remaining_args = extract_hash_args(args_str) do |key, value|
            specific_atoms[key] =
              specify_atom_for(specific_atoms[key], spec, key, value)
          end

          remaining_args.each do |arg|
            syntax_error('specific_spec.wrong_specification', atom: arg)
          end
        end
        specific_atoms
      end

      # Specifies atom for passed spec by key and value from specific spec
      # options
      #
      # @param [Concepts::SpecificAtom] atom the specifing atom
      # @param [Concepts::Spec] spec the atom of which is defined herein
      # @param [Symbol] key the keyname of atom in spec
      # @param [String] value from which will be setuping atom
      def specify_atom_for(atom, spec, key, value)
        unless atom
          atom = spec.atom(key)
          unless atom
            syntax_error('specific_spec.wrong_specification', atom: key)
          end

          atom = Concepts::SpecificAtom.new(atom)
        end

        apply_state_to(atom, value) do |mma|
          if !mma || mma.valence > 1
            syntax_error('specific_spec.wrong_specification', atom: key)
          end
        end

        atom
      rescue Concepts::SpecificAtom::AlreadyUnfixed
        syntax_warning('specific_spec.atom_already_unfixed',
          spec: spec.name, atom: key)
      rescue Concepts::SpecificAtom::AlreadyStated
        syntax_error('specific_spec.atom_already_has_state',
          spec: spec.name, atom: key, state: value)
      end

      # Applies state from value string to atom
      # @param [SpecificAtom] atom which will be setuped
      # @param [String] value from which will be setuping atom
      # @yield [Concepts::Atom] using for checking monovalent atom
      def apply_state_to(atom, value, &checking_block)
        case value
        when 'i'
          atom.incoherent!
        when 'u'
          atom.unfixed!
        when /\A\*+\Z/
          value.scan('*').size.times do
            atom.active!
          end
        else
          monoatom = get_atom(value)
          checking_block[monoatom]
          atom.use!(monoatom)
        end
      end

      # Gets atom from Chest if it is
      # @param [String] name the name of atom
      # @return [Concepts::Atom] the stored atom or nil
      def get_atom(name)
        Tools::Chest.atom(name)
      rescue Tools::Chest::KeyNameError
        nil
      end
    end

  end
end
